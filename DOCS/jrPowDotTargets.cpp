#include <iostream>
#include <cstdint> // For uint16_t, uint32_t, etc.

uint16_t swap_bytes_16(uint16_t value) {
    return (value << 8) | (value >> 8);
}

int main()
{
    //unsigned short vals[] = {0x4067, 0x407B, 0x424E, 0x44EE, 0x46C7, 0x46DB}; // MAZE "0"
    //unsigned short vals[] = {0x4065, 0x407A, 0x424E, 0x44EE, 0x46C5, 0x46DA}; // MAZE "1"
    //unsigned short vals[] = {0x4065, 0x407D, 0x41EE, 0x454E, 0x46C5, 0x46DD}; // MAZE "2"
    //unsigned short vals[] = {0x4065, 0x407B, 0x4248, 0x44E8, 0x46C5, 0x46DB}; // MAZE "3"
    //unsigned short vals[] = {0x4137, 0x4188, 0x45A8, 0x4617, 0x4137, 0x4188}; // MAZE "4"
    //unsigned short vals[] = {0x40C5, 0x419A, 0x424E, 0x44EE, 0x45BA, 0x4665}; // MAZE "5"
    //unsigned short vals[] = {0x4128, 0x4137, 0x4608, 0x4617, 0x4128, 0x4137}; // MAZE "6"
    
    for (int i = 0; i < 6; i++)
    {
        unsigned short val = vals[i] - 0x4000;
        
        unsigned char val8L = ((val & 0xFF) & 0x1F) + 0x20;
        
        val /= 32;
        
        unsigned char val8H = (val & 0xFF) + 0x1E;
        
        // X/Y
        unsigned short res = (val8H * 0x100) | val8L;
        
        std::cout << std::hex << swap_bytes_16(res) << " ";
    }
    

    return 0;
}