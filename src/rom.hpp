#pragma once

#include <cstdint>
#include <string>
#include <variant>
#include <vector>

enum class RomError { None, NotFound, Unreadable, NoRomInZip, Unsupported, TooBig };

struct Rom {
    std::vector<uint8_t> data;
    std::string innerName;  // entry name when loaded from an archive, empty otherwise
};

// .gba/.agb are read whole; for .zip and .7z the first .gba/.agb entry in archive order.
// Limits, checked before reading: 32 MiB for the ROM (the largest GBA ROM is 32 MiB)
// and 48 MiB for an archive; bigger gives TooBig.
std::variant<Rom, RomError> loadRom(const std::string& path);
