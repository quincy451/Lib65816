#include "Cpu65816.hpp"
#include "SystemBus.hpp"
#include "SystemBusDevice.hpp"

#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

constexpr uint16_t kResultCodeAddr = 0x00FE;
constexpr uint16_t kStatusAddr = 0x00FF;
constexpr uint8_t kPass = 0xAA;
constexpr uint8_t kFail = 0xFF;
constexpr size_t kMaxSteps = 200000;

class Bank0Ram final : public SystemBusDevice {
public:
    explicit Bank0Ram(size_t size) : mem_(size, 0) {}

    void load(const std::vector<uint8_t> &image) {
        if (image.size() > mem_.size()) {
            throw std::runtime_error("binary too large for bank 0 RAM");
        }
        for (size_t i = 0; i < image.size(); ++i) {
            mem_[i] = image[i];
        }
    }

    void storeByte(const Address &address, uint8_t value) override {
        Address decoded;
        if (!decodeAddress(address, decoded)) {
            throw std::runtime_error("unmapped store");
        }
        mem_[decoded.getOffset()] = value;
    }

    uint8_t readByte(const Address &address) override {
        Address decoded;
        if (!decodeAddress(address, decoded)) {
            throw std::runtime_error("unmapped read");
        }
        return mem_[decoded.getOffset()];
    }

    bool decodeAddress(const Address &address, Address &decoded) override {
        if (address.getBank() != 0x00) {
            return false;
        }
        decoded = Address(0x00, address.getOffset());
        return true;
    }

private:
    std::vector<uint8_t> mem_;
};

std::vector<uint8_t> readBinary(const std::string &path) {
    std::ifstream in(path, std::ios::binary);
    if (!in) {
        throw std::runtime_error("failed to open binary: " + path);
    }
    return std::vector<uint8_t>(std::istreambuf_iterator<char>(in), {});
}

} // namespace

int main(int argc, char **argv) {
    if (argc != 2) {
        std::cerr << "usage: run65816_smoke <binary>\n";
        return 2;
    }

    auto image = readBinary(argv[1]);

    SystemBus bus;
    Bank0Ram ram(BANK_SIZE_BYTES);
    ram.load(image);
    bus.registerDevice(&ram);

    const EmulationModeInterrupts emuVectors{0xFFF4, 0xFFF6, 0xFFF8, 0xFFFA, 0xFFFC, 0xFFFE};
    const NativeModeInterrupts nativeVectors{0xFFE4, 0xFFE6, 0xFFE8, 0xFFEA, 0xFFFC, 0xFFEE};

    Cpu65816 cpu(bus, const_cast<EmulationModeInterrupts *>(&emuVectors),
                 const_cast<NativeModeInterrupts *>(&nativeVectors));
    cpu.setRESPin(false);

    for (size_t step = 0; step < kMaxSteps; ++step) {
        if (!cpu.executeNextInstruction()) {
            const auto pc = cpu.getProgramAddress();
            std::cerr << "FAIL 65816 halted steps=" << step
                      << " bank=" << +pc.getBank()
                      << " pc=0x" << std::hex << pc.getOffset() << std::dec
                      << " code=" << +ram.readByte(Address(0x00, kResultCodeAddr))
                      << "\n";
            break;
        }

        const auto status = ram.readByte(Address(0x00, kStatusAddr));
        if (status == kPass) {
            std::cout << "PASS 65816 steps=" << (step + 1)
                      << " code=" << +ram.readByte(Address(0x00, kResultCodeAddr))
                      << "\n";
            return 0;
        }
        if (status == kFail) {
            const auto pc = cpu.getProgramAddress();
            std::cerr << "FAIL 65816 steps=" << (step + 1)
                      << " code=" << +ram.readByte(Address(0x00, kResultCodeAddr))
                      << " bank=" << +pc.getBank()
                      << " pc=0x" << std::hex << pc.getOffset()
                      << " a=0x" << cpu.getA()
                      << std::dec
                      << "\n";
            return 1;
        }
    }

    std::cerr << "FAIL 65816 timeout code="
              << +ram.readByte(Address(0x00, kResultCodeAddr))
              << " pc=0x" << std::hex << cpu.getProgramAddress().getOffset() << std::dec
              << "\n";
    return 1;
}
