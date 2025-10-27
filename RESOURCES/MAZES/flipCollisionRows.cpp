#include <cstdint>
#include <cstddef>
#include <cstdio>
#include <iostream>
#include <algorithm>

// Swap two nibbles inside a byte: ab -> ba
uint8_t swap_nibbles(uint8_t b) {
    //uint8_t nibbleH = (b >> 4) & 0x0F;
    //uint8_t nibbleL = b & 0x0F;

    //return (nibbleL << 4) | nibbleH;
    return uint8_t((b << 4) | (b >> 4));
}

// Reverse 32 packed nibbles stored as 16 bytes in-place.
// row: pointer to 16 bytes
// nibble0_is_high: true if logical nibble 0 == high nibble of byte 0
void reverse_32_nibbles_inplace_row(uint8_t* row) {
    // swap pairs row[i] <-> row[15-i] for i=0..7
    for (int i = 0; i < 8; ++i) {
        int j = 15 - i;
        uint8_t a = row[i];
        uint8_t b = row[j];
        row[i] = swap_nibbles(b);
        row[j] = swap_nibbles(a);
    }
    /*
    for (int i = 0; i < 8; i++)
    {
        uint8_t swap0 = swap_nibbles(row[15 - i]);
        uint8_t swap1 = swap_nibbles(row[i]);

        row[i] = swap0;
        row[15 - i] = swap1;
    }
    */


}

// Apply to multiple rows. data points to first byte of row0.
// rows = number of rows (e.g. 31).
// stride_bytes = bytes between starts of consecutive rows (defaults to 16).
void reverse_n_rows(uint8_t* data, int rows) {
    /*
    uint8_t* p = data;
    for (int r = 0; r < rows; ++r) {
        reverse_32_nibbles_inplace_row(p);
        p += 16;
    }
    */
   for (int r = 0; r < rows; ++r) {
        reverse_32_nibbles_inplace_row(data + r * 16);
    }
}

// Example usage
int main() {
    uint8_t buffer[31 * 16];


    // OPEN BMP FILE
    FILE *bmpFile = fopen("COL_MAZE.BIN", "rb");
        // IF CAN'T OPEN, ERROR
    if (bmpFile == NULL)
	{
		std::cerr << "Couldn't open COL_MAZE.BIN!\n";
		return 1;
	}
    // STORE IMAGE DATA IN VECTOR
    for (int i = 0; i < 496; i++)
    {
        unsigned char byte;
        fread(&byte, 1, 1, bmpFile);
        buffer[i] = byte;
    }

    fclose(bmpFile);

    // If nibble 0 corresponds to the high nibble of byte 0:
    reverse_n_rows(buffer, 31);


    FILE *outBmp = fopen("COL_MAZE_R.BIN", "wb");
    if (!outBmp) 
    {
        std::cerr << "Couldn't create COL_MAZE_R.BIN!\n";
        return 1;
    }

    // WRITE HEADER
    fwrite(buffer, 1, 496, outBmp);


    fclose(outBmp);

    return 0;
}
