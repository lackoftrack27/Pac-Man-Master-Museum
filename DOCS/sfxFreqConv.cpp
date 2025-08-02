/******************************************************************************

                              Online C++ Compiler.
               Code, Compile, Run and Debug C++ program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <iostream>
#include <iomanip>
#include <cmath> // Required for std::round()

#define CHAN_1_BITS 32768
#define CHAN_2_BITS 2048

#define WRITE_SMPS  1

void printInfo(unsigned short freq)
{
    
    double freqD = freq;
    double freqHZ = (freqD/CHAN_2_BITS) * 3000;
    unsigned short psgFreq = std::round(3579545/(32 * freqHZ));
    double psgFreqHZ = 3579545/static_cast<double>(32 * psgFreq);
    double deltaHZ = std::abs(psgFreqHZ - freqHZ);
    
    
    #if WRITE_SMPS != 1
    std::cout << "WSG REG: $" << std::hex << freq << "\t";
    std::cout << "WSG HZ: " << freqHZ << "\t";
    
    if (psgFreq > 0x3FF)
        std::cout << "Low Frequency Limit!!!\t";
    else
        std::cout << "PSG REG: $" << std::hex << psgFreq << "\t";
        
    std::cout << "PSG HZ: " << psgFreqHZ << "\t";
    std::cout << "HZ Delta: " << deltaHZ << "\t";
        
    #else
    
    if (psgFreq > 0x3FF)
        std::cout << "literalWord\t$03FF\t; LOW FREQ LIMIT";
    else
        std::cout << "literalWord\t$" << std::hex << std::setfill('0') << std::setw(4) << psgFreq;
    
    #endif
    
    
    
    
    std::cout << "\n";
}

int main()
{
    // CHANNEL 1 EFFECTS
    //unsigned char bytes[] = {0x73, 0x20, 0x00, 0x0C, 0x00, 0x0A, 0x1f, 0x00};   // 1up (hz * 2)
    //unsigned char bytes[] = {0x72, 0x20, 0xfb, 0x87, 0x00, 0x02, 0x0f, 0x00};   // credit (hz * 16)
    
    
    //  --------------------------- PAC-MAN ---------------------------
    
    // CHANNEL 2 EFFECTS
    //unsigned char bytes[] = {0x36, 0x20, 0x04, 0x8c, 0x00, 0x00, 0x06, 0x00};   // siren 0 [pacman]
    //unsigned char bytes[] = {0x36, 0x28, 0x05, 0x8b, 0x00, 0x00, 0x06, 0x00}; // siren 1 [pacman]
    //unsigned char bytes[] = {0x36, 0x30, 0x06, 0x8a, 0x00, 0x00, 0x06, 0x00}; // siren 2 [pacman]
    //unsigned char bytes[] = {0x36, 0x3c, 0x07, 0x89, 0x00, 0x00, 0x06, 0x00}; // siren 3 [pacman]
    //unsigned char bytes[] = {0x36, 0x48, 0x08, 0x88, 0x00, 0x00, 0x06, 0x00}; // siren 4 [pacman]
    //unsigned char bytes[] = {0x24, 0x00, 0x06, 0x08, 0x00, 0x00, 0x0a, 0x00}; // scared [pacman] (hz * 8)
    //unsigned char bytes[] = {0x40, 0x70, 0xfa, 0x10, 0x00, 0x00, 0x0a, 0x00}; // eyes [pacman]
    //unsigned char bytes[] = {0x70, 0x04, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00}; // test [pacman]
    
    
    // CHANNEL 3 EFFECTS
    //unsigned char bytes[] = {0x42, 0x18, 0xFD, 0x06, 0x00, 0x01, 0x0C, 0x00}; // dot 0 [pacman] (hz * 16)
    //unsigned char bytes[] = {0x42, 0x04, 0x03, 0x06, 0x00, 0x01, 0x0C, 0x00}; // dot 1 [pacman] (hz * 16)
    //unsigned char bytes[] = {0x56, 0x0c, 0xff, 0x8c, 0x00, 0x02, 0x0f, 0x00}; // fruit ate
    //unsigned char bytes[] = {0x05, 0x00, 0x02, 0x20, 0x00, 0x01, 0x0c, 0x00}; // ghost ate [pacman] (hz * 16)
    //unsigned char bytes[] = {0x42, 0x20, 0xFF, 0x86, 0xFE, 0x1C, 0x0F, 0x00};   // death 0 [pacman]
    //unsigned char bytes[] = {0x70, 0x00, 0x01, 0x0c, 0x00, 0x01, 0x08, 0x00};   // death 1 [pacman]
    
    //  --------------------------- MS. PAC-MAN ---------------------------
    
    // CHANNEL 2 EFFECTS
    unsigned char bytes[] = {0x59, 0x01, 0x06, 0x08, 0x00, 0x00, 0x02, 0x00};   // siren 0 [mspacman]
    //unsigned char bytes[] = {0x59, 0x01, 0x06, 0x09, 0x00, 0x00, 0x02, 0x00}; // siren 1 [mspacman]
    //unsigned char bytes[] = {0x59, 0x02, 0x06, 0x0a, 0x00, 0x00, 0x02, 0x00}; // siren 2 [mspacman]
    //unsigned char bytes[] = {0x59, 0x03, 0x06, 0x0b, 0x00, 0x00, 0x02, 0x00}; // siren 3 [mspacman]
    //unsigned char bytes[] = {0x59, 0x04, 0x06, 0x0c, 0x00, 0x00, 0x02, 0x00}; // siren 4 [mspacman]
    //unsigned char bytes[] = {0x24, 0x00, 0x06, 0x08, 0x02, 0x00, 0x0a, 0x00}; // scared [mspacman] (hz * 4)
    //unsigned char bytes[] = {0x36, 0x07, 0x87, 0x6f, 0x00, 0x00, 0x04, 0x00}; // eyes [mspacman]
    
    
    // CHANNEL 3 EFFECTS
    //unsigned char bytes[] = {0x1c, 0x70, 0x8b, 0x08, 0x00, 0x01, 0x06, 0x00}; // dot [mspacman] (hz * 8)
    //unsigned char bytes[] = {0x56, 0x00, 0x02, 0x0a, 0x07, 0x03, 0x0c, 0x00}; // ghost ate [mspacman]
    //unsigned char bytes[] = {0x36, 0x38, 0xfe, 0x12, 0xf8, 0x04, 0x0f, 0xfc}; // death [mspacman]
    //unsigned char bytes[] = {0x22, 0x01, 0x01, 0x06, 0x00, 0x01, 0x07, 0x00}; // fruit bounce [mspacman] (hz * 16)
    
    
    // EFFECT TABLE SETUP
    unsigned char octaveShift = (bytes[0] >> 0x04) & 0x07;
    unsigned char baseFreq = bytes[1];
    unsigned char freqInc = bytes[2];
    bool reverse = (bytes[3] & 0x80) >> 0x07;
    unsigned char duration = bytes[3] & 0x7F;
    unsigned char freqIncRep = bytes[4];
    unsigned char reps = bytes[5];
    unsigned char fade = (bytes[6] >> 0x04) & 0x0F;
    unsigned char initVol = bytes[6] & 0x0F;
    unsigned char volIncRep = bytes[7];
    
    // NO INFINITE REPS
    if (reps == 0)
    {
        reps = 64;
    }
    
    unsigned char baseFreqCounter = baseFreq;
    unsigned short freq;
    int durCounter = duration - 1;
    
    
    for (int x = 0; x < reps; x++)
    {
        // FOR DURATION COUNTER
        while (durCounter-- != 0)
        {
            // UPDATE FREQUENCY
            baseFreqCounter += freqInc;
            freq = (baseFreqCounter << octaveShift);
            // PRINT INFO
            printInfo(freq);
        }
        
        // RESET DURATION COUNTER
        durCounter = duration;
        
        if (reverse == true)
        {
            // NEGATE INCREMENT
            freqInc = -freqInc;

            // EVERY OTHER REPEAT
            if (x != 0 && (x & 0x01) != 0)
            {
                baseFreq += freqIncRep;     // TABLE_1 += TABLE_4
                baseFreqCounter = baseFreq; // BASE_FREQ = TABLE_1
            }
        }
        else
        {
            // EVERY REPEAT
            baseFreq += freqIncRep;     // TABLE_1 += TABLE_4
            baseFreqCounter = baseFreq; // BASE_FREQ = TABLE_1
        }
        std::cout << "\n";
    }
    
    

    return 0;
}