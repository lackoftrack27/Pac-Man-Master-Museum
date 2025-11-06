#include <iostream>
#include <vector>
#include <unordered_set>
#include <array>
#include <algorithm>
#include <cstring>
#include <cstdio>
#include <cassert>

#define JR          1


#define CLR_BLACK   0

#define CLR_DOT_0   7
#define CLR_DOT_1   8
#define CLR_DOT_2   9

#define CLR_POW_0   10
#define CLR_POW_1   11
#define CLR_POW_2   12
#define CLR_POW_3   13

#define TILE_SIZE   32

#if JR == 0
#define TILEX_COUNT     21
#define TILEY_COUNT     24
#else
#define TILEX_COUNT     41
#define TILEY_COUNT     23
#endif


#define ROW_SIZE        TILEX_COUNT * 4
#define TOTALROW_SIZE   ROW_SIZE * 8
#define IMG_DATA_SIZE   TILEX_COUNT * TILEY_COUNT * TILE_SIZE


#define OUTHEADER_SIZE  118

const unsigned char outHeader[] = 
{
    0x42, 0x4d,             // SIG
    0x00, 0x00, 0x00, 0x00, // FILE SIZE (MUST CHANGE!!!)
    0x00, 0x00, 0x00, 0x00, // REVERSED
    0x76, 0x00, 0x00, 0x00, // DATA OFFSET
    0x28, 0x00, 0x00, 0x00, // INFO HEADER SIZE
    0x80, 0x00, 0x00, 0x00, // WIDTH [16 TILES * 8]
    0x00, 0x00, 0x00, 0x00, // HEIGHT (MUST CHANGE!!!)
    0x01, 0x00,             // PLANE
    0x04, 0x00,             // COLOR TYPE
    0x00, 0x00, 0x00, 0x00, // COMPRESSION
    0x00, 0x00, 0x00, 0x00, // COMPRESSED SIZE
    0xc4, 0x0e, 0x00, 0x00, // X PIXEL PER M
    0xc4, 0x0e, 0x00, 0x00, // Y PIXEL PER M
    0x10, 0x00, 0x00, 0x00, // COLORS USED
    0x10, 0x00, 0x00, 0x00, // NUM OF IMPORTANT COLORS
    // COLOR TABLE (BGRA)
    0x00, 0x00, 0x00, 0x00, // TRANSPARENT
    0xff, 0x00, 0x00, 0x00, // MAZE WALLS
    0x00, 0x00, 0xff, 0x00, // MAZE INSIDES
    0xaa, 0x00, 0x00, 0x00, // MAZE SHADING 0
    0x55, 0x00, 0x00, 0x00, // MAZE SHADING 1
    0xff, 0xff, 0x00, 0x00, // MAZE SHADING 2
    0xff, 0xaa, 0xff, 0x00, // GHOST GATE
    0xaa, 0xaa, 0xff, 0x00, // DOT 0
    0x55, 0x55, 0xaa, 0x00, // DOT 1
    0x00, 0x00, 0x55, 0x00, // DOT 2
    0x00, 0xff, 0x00, 0x00, // POWER DOT 0
    0x00, 0xaa, 0x00, 0x00, // POWER DOT 1
    0x00, 0x55, 0x00, 0x00, // POWER DOT 2
    0x00, 0xff, 0xff, 0x00, // POWER DOT 3
    0x00, 0x00, 0x00, 0x00, // UNUSED
    0x00, 0x00, 0x00, 0x00, // UNUSED
};

const int quad0Arr[] = {0, 1, 4, 5, 8, 9, 12, 13};
const int quad1Arr[] = {16, 17, 20, 21, 24, 25, 28, 29};
const int quad2Arr[] = {2, 3, 6, 7, 10, 11, 14, 15};
const int quad3Arr[] = {18, 19, 22, 23, 26, 27, 30, 31};
//const int* quadPtrs[] = {quad0Arr, quad1Arr, quad2Arr, quad3Arr};
const int* quadPtrs[] = {quad3Arr, quad2Arr, quad0Arr, quad1Arr};
const int dotMatch[] = {2, 3, 1, 0};


struct tile 
{
    // 8px X 8px
    // EACH BYTE REPRESENTS 2 PIXELS (4BPP)
    unsigned char data[32];
};


unsigned char swapNibbles(unsigned char val)
{
    return ((val & 0x0F) << 4) | ((val & 0xF0) >> 4);
}

tile flipTileH(tile& t)
{
    // 01 23 45 67 -> 76 54 32 10
    tile out;
    for (int i = 0; i < 8; i++)
    {
        out.data[i * 4 + 0] = swapNibbles(t.data[i * 4 + 3]);
        out.data[i * 4 + 1] = swapNibbles(t.data[i * 4 + 2]);
        out.data[i * 4 + 2] = swapNibbles(t.data[i * 4 + 1]);
        out.data[i * 4 + 3] = swapNibbles(t.data[i * 4 + 0]);
    }

    return out;
}
tile flipTileV(tile& t)
{
    // 01 23 45 67 -> ...
    // 76 54 32 10 -> 76 54 32 10
    // ...         -> 01 23 45 67
    tile out;
    for (int i = 0; i < 8; i++)
    {
        // Each row is 4 bytes (2 pixels per byte, 8 pixels total)
        for (int j = 0; j < 4; j++)
        {
            out.data[(7 - i) * 4 + j] = t.data[i * 4 + j];
        }
    }

    return out;
}
tile flipTileHV(tile& t)
{
    tile out = flipTileH(t);
    out = flipTileV(out);
    return out;
}

bool tilesEqual(const tile& a, const tile& b) 
{
    return memcmp(a.data, b.data, 32) == 0;
}

// TRUE - MATCH, FALSE - NO MATCH
bool compareTiles(tile& a, tile& b)
{
    tile temp;
    // COMPARE NORMAL
    if (tilesEqual(a, b) == true)
        return true;
    // COMPARE FLIP H
    temp = flipTileH(a);
    if (tilesEqual(temp, b) == true)
        return true;
    // COMPARE FILP V
    temp = flipTileV(a);
    if (tilesEqual(temp, b) == true)
        return true;
    // COMPARE FLIP HV
    temp = flipTileHV(a);
    if (tilesEqual(temp, b) == true)
        return true;
    return false;
}

/*
    Q0 Q0 Q2 Q2 
    Q0 Q0 Q2 Q2 
    Q0 Q0 Q2 Q2
    Q0 Q0 Q2 Q2
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
*/

tile blankoutQuad(const tile& t, int quadNum)
{
    tile out = t;

    const int *quadPtr = quadPtrs[quadNum];

    for (int i = 0; i < 8; i++)
    {
        int idx = quadPtr[i];
        out.data[idx] = 0;
    }

    return out;
}

tile mutateQuad(const tile& t, int quadNum)
{
    tile out = t;

    const int *quadPtr = quadPtrs[quadNum];

    bool color2 = false;
    for (int i = 0; i < 8; i++)
    {
        int idx = quadPtr[i];
        if (out.data[idx] == (CLR_DOT_0 << 4 | CLR_DOT_0) ||
        out.data[idx] == (CLR_DOT_1 << 4 | CLR_DOT_1) ||
        out.data[idx] == (CLR_DOT_2 << 4 | CLR_DOT_2))
        {
            /*
            if (color2 == false)
                out.data[idx] = 0x12;
            else
                out.data[idx] = 0x21;
            */
            out.data[idx] = 0x22;

            color2 = true;
        }
    }

    return out;
}

tile mutateToNormal(const tile& t) 
{
    tile out = t;
    for (int i = 0; i < 32-4; i++) {
        if (out.data[i] == 0x22 && out.data[i+4] == 0x22)
        {
            out.data[i] = ((CLR_DOT_0 << 4) | CLR_DOT_0);
            out.data[i+4] = ((CLR_DOT_0 << 4) | CLR_DOT_0);
        }
    }
    return out;
}

// Get color index at (x, y) from tile
unsigned char getPixel(const tile& t, int x, int y) {
    int byteIndex = y * 4 + x / 2;
    if (x % 2 == 0)
        return (t.data[byteIndex] >> 4) & 0x0F;
    else
        return t.data[byteIndex] & 0x0F;
}

// Set color index at (x, y) in tile
void setPixel(tile& t, int x, int y, unsigned char value) {
    int byteIndex = y * 4 + x / 2;
    if (x % 2 == 0)
        t.data[byteIndex] = (t.data[byteIndex] & 0x0F) | (value << 4);
    else
        t.data[byteIndex] = (t.data[byteIndex] & 0xF0) | (value & 0x0F);
}

void removeDuplicates(std::vector<tile>& tileBank)
{
    for (int i = 0; i < tileBank.size(); i++)
    {
        for (int j = i + 1; j < tileBank.size(); )
        {
            if (compareTiles(tileBank[i], tileBank[j]))
            {
                tileBank.erase(tileBank.begin() + j);
                // DO NOT increment j — next tile now at index j
            }
            else
            {
                j++; // Only increment if no erase
            }
        }
    }
}


bool containsColor(const tile& t, const unsigned char minColor, const unsigned char maxColor)
{
    for (int i = 0; i < 32; i++) {
        unsigned char byte = t.data[i];
        unsigned char left = (byte >> 4) & 0x0F;
        unsigned char right = byte & 0x0F;

        if (left >= minColor && left <= maxColor) return true;
        if (right >= minColor && right <= maxColor) return true;
    }
    return false;
}


// Zero out specific indices in tile
void removeIndicesFromTile(tile* src, tile* dst, const int* indices, int num_indices) {
    for (int i = 0; i < 32; i++) {
        unsigned char b = src->data[i];
        unsigned char hi = (b & 0xF0) >> 4;
        unsigned char lo = (b & 0x0F);
        for (int j = 0; j < num_indices; j++) {
            if (hi == indices[j]) hi = 0;
            if (lo == indices[j]) lo = 0;
        }
        dst->data[i] = (hi << 4) | lo;
    }
}

// Match tile in bank, return index and flip flags
bool findMatchingTileIndex(tile* src, std::vector<tile>& tileBank, int* index_out, int* flipH, int* flipV) {
    tile temp;
    for (int i = 0; i < tileBank.size(); i++) {
        if (memcmp(src->data, tileBank[i].data, 32) == 0) {
            *index_out = i;
            *flipH = 0;
            *flipV = 0;
            return true;
        }

        temp = flipTileH(*src);
        if (memcmp(temp.data, tileBank[i].data, 32) == 0) {
            *index_out = i;
            *flipH = 1;
            *flipV = 0;
            return true;
        }

        temp = flipTileV(*src);
        if (memcmp(temp.data, tileBank[i].data, 32) == 0) {
            *index_out = i;
            *flipH = 0;
            *flipV = 1;
            return true;
        }

        temp = flipTileHV(*src);
        if (memcmp(temp.data, tileBank[i].data, 32) == 0) {
            *index_out = i;
            *flipH = 1;
            *flipV = 1;
            return true;
        }
    }
    return false;
}

/*
    Q0 Q0 Q2 Q2 
    Q0 Q0 Q2 Q2 
    Q0 Q0 Q2 Q2
    Q0 Q0 Q2 Q2
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
    Q1 Q1 Q3 Q3
*/

// Extract quadrant from tile into new tile struct (top-left = quadrant 0, etc.)
void extractQuadrant(tile* src, tile* dst, int quadrant) {
    memset(dst->data, 0, 32);
    int startX = (quadrant == 0 || quadrant == 1) ? 0 : 2;
    int startY = (quadrant == 0 || quadrant == 2) ? 0 : 4;

    for (int y = 0; y < 4; y++) {
        int srcY = startY + y;
        for (int x = 0; x < 2; x++) {
            int srcX = startX + x;
            int byteIndex = srcY * 4 + srcX / 2;
            unsigned char byte = src->data[byteIndex];
            unsigned char pixel = (srcX % 2 == 0) ? (byte >> 4) : (byte & 0x0F);

            // write to dst
            int dstByteIndex = y * 4 + x / 2;
            if (x % 2 == 0)
                dst->data[dstByteIndex] |= (pixel << 4);
            else
                dst->data[dstByteIndex] |= pixel;
        }
    }
}


int main() 
{
    // PAC-MAN / MS.PAC-MAN
    /*
    INPUT BMP: 4-BIT, 168px X 192px (21 * 24)
    OUTPUT BMP: 4-BIT, 128px X (numofTiles / 16) * 8

    IMAGE DATA SIZE: 16128 bytes
    */

    // JR PAC-MAN
    /*
    INPUT BMP: 4-BIT, 328px X 184px (41 * 23)
    OUTPUT BMP: 4-BIT, 128px X (numofTiles / 16) * 8

    IMAGE DATA SIZE: 30176 bytes
    */

    std::vector<unsigned char> imgData;
    imgData.reserve(IMG_DATA_SIZE);

    std::vector<tile> originalTileGrid;
    std::vector<tile> tileBank;
    
    // OPEN BMP FILE
    FILE *bmpFile = fopen("maze.bmp", "rb");
        // IF CAN'T OPEN, ERROR
    if (bmpFile == NULL)
	{
		std::cerr << "Couldn't open maze.bmp!\n";
		return 1;
	}
    // SEEK TO DATA OFFSET
    fseek(bmpFile, 0x000A, SEEK_SET);
    // GET DATA OFFSET
    uint32_t inImgDataOffset;
    fread(&inImgDataOffset, sizeof(int), 1, bmpFile);
    // SEEK TO DATA
    fseek(bmpFile, inImgDataOffset, SEEK_SET);
    // STORE IMAGE DATA IN VECTOR
    for (int i = 0; i < IMG_DATA_SIZE; i++)
    {
        unsigned char byte;
        fread(&byte, 1, 1, bmpFile);
        imgData.push_back(byte);
    }
    // CLOSE FILE
    fclose(bmpFile);

    // ADD TILES TO BANK
    // -------------------------------
        // SIZE OF ROW: 84
        // SIZE OF TILE ROW: 4
        // SIZE OF TOTAL TILE ROW: 672 (8 * 84)
    for (int y = 0; y < TILEY_COUNT; y++)
    {
        for (int x = 0; x < TILEX_COUNT; x++)
        {
            tile tempTile;
            for (int i = 0; i < 8; i++)
            {
                memcpy(tempTile.data + (i * 4), &imgData[(y * TOTALROW_SIZE) + (x * 4) + (i * ROW_SIZE)], 4);
            }
            tileBank.push_back(tempTile);
            originalTileGrid.push_back(tempTile);
        }
    }
    // -------------------------------

    // REMOVE DUPLICATE TILES
    // -------------------------------
    removeDuplicates(tileBank);
    // -------------------------------


    // SORT ORIGINAL TILESET
    // -------------------------------
    std::vector<tile> allBlackTiles;
    std::vector<tile> dotTiles;
    std::vector<tile> powerTiles;
    std::vector<tile> otherTiles;

    auto isAllBlack = [](const tile& t) 
    {
        for (int i = 0; i < 32; i++) 
        {
            if (t.data[i] != 0)
                return false;
        }
        return true;
    };

    for (const tile& t : tileBank) 
    {
        if (isAllBlack(t)) 
        {
            allBlackTiles.push_back(t);
        }
        else if (containsColor(t, CLR_DOT_0, CLR_DOT_2) == true)
        {
            dotTiles.push_back(t);
        }
        else if (containsColor(t, CLR_POW_0, CLR_POW_3) == true)
        {
            powerTiles.push_back(t);
        }
        else 
        {
            otherTiles.push_back(t);
        }
    }

    tileBank.clear();
        // BLANK
    tileBank.insert(tileBank.end(), allBlackTiles.begin(), allBlackTiles.end());
        // DOT TILES
    tileBank.insert(tileBank.end(), dotTiles.begin(), dotTiles.end());
        // POW TILES
    tileBank.insert(tileBank.end(), powerTiles.begin(), powerTiles.end());
    // -------------------------------

    // GENERATE NEW DOT TILES
    // -------------------------------
    std::vector<tile> newTiles;
    for (int z = 0; z < 4; z++)     // UP TO 4 DOTS IN ONE TILE
    {
        for (const tile& t : tileBank) 
        {
            // FOR ALL 4 QUADRANTS
            for (int i = 0; i < 4; i++)
            {
                bool foundDot = false;
                const int *quadPtr = quadPtrs[i];

                // CHECK FOR DOT INDEXES
                for (int j = 0; j < 8; j++)
                {
                    int idx = quadPtr[j];
                    unsigned char lNibble = t.data[idx] & 0x0F;
                    unsigned char hNibble = (t.data[idx] & 0xF0) >> 4;

                    if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                        foundDot = true;
                    else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                        foundDot = true;
                }
                // IF FOUND, REMOVE DOT AND ADD TO VECTOR
                if (foundDot == true)
                {
                    tile blanked = blankoutQuad(t, i);
                    newTiles.push_back(blanked);
                }
            }
        }
        // Append modified tiles
        tileBank.insert(tileBank.end(), newTiles.begin(), newTiles.end());
    }
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);
    // -------------------------------


    // GENERATE NEW POWER DOT TILES
    // -------------------------------
    std::vector<tile> powerCleanedTiles;

    for (const tile& t : tileBank) {
        bool hasPower = false;

        // First scan the tile to check if it contains any of the power indices
        if (containsColor(t, CLR_POW_0, CLR_POW_3) == true)
            hasPower = true;

        if (hasPower) 
        {
            tile cleaned = t;

            // Now zero out all matching power colors
            for (int y = 0; y < 8; y++) 
            {
                for (int x = 0; x < 8; x++) 
                {
                    unsigned char px = getPixel(cleaned, x, y);
                    if (px == CLR_POW_0 || px == CLR_POW_1 || px == CLR_POW_2 || px == CLR_POW_3) 
                    {
                        setPixel(cleaned, x, y, CLR_BLACK);
                    }
                }
            }

            powerCleanedTiles.push_back(cleaned);
        }
    }
        // Add to tileBank
    tileBank.insert(tileBank.end(), powerCleanedTiles.begin(), powerCleanedTiles.end());
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);
    const int DOT_TABLE_SIZE = tileBank.size();
    // -------------------------------

    #if JR == 1
    // GENERATE NEW MUTATED DOT TILES
    // -------------------------------
    std::vector<tile> mutatedDotTiles;
    for (int z = 0; z < 4; z++)     // UP TO 4 DOTS IN ONE TILE
    {
        for (const tile& t : tileBank) 
        {
            // FOR ALL 4 QUADRANTS
            for (int i = 0; i < 4; i++)
            {
                bool foundDot = false;
                const int *quadPtr = quadPtrs[i];

                // CHECK FOR DOT INDEXES
                for (int j = 0; j < 8; j++)
                {
                    int idx = quadPtr[j];
                    unsigned char lNibble = t.data[idx] & 0x0F;
                    unsigned char hNibble = (t.data[idx] & 0xF0) >> 4;

                    if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                        foundDot = true;
                    else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                        foundDot = true;
                }
                // IF FOUND, MUTATE DOT AND ADD TO VECTOR
                if (foundDot == true)
                {
                    tile blanked = mutateQuad(t, i);
                    mutatedDotTiles.push_back(blanked);
                }
            }
        }
        // Append modified tiles
        tileBank.insert(tileBank.end(), mutatedDotTiles.begin(), mutatedDotTiles.end());
    }
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);
    // -------------------------------


    // GENERATE NEW POWER DOT TILES MUTATED
    // -------------------------------
    std::vector<tile> powerCleanedTilesMutated;

    for (const tile& t : tileBank) {
        bool hasPower = false;

        // First scan the tile to check if it contains any of the power indices
        if (containsColor(t, CLR_POW_0, CLR_POW_3) == true)
            hasPower = true;

        if (hasPower) 
        {
            tile cleaned = t;

            // Now zero out all matching power colors
            for (int y = 0; y < 8; y++) 
            {
                for (int x = 0; x < 8; x++) 
                {
                    unsigned char px = getPixel(cleaned, x, y);
                    if (px == CLR_POW_0 || px == CLR_POW_1 || px == CLR_POW_2 || px == CLR_POW_3) 
                    {
                        setPixel(cleaned, x, y, CLR_BLACK);
                    }
                }
            }

            powerCleanedTilesMutated.push_back(cleaned);
        }
    }
        // Add to tileBank
    tileBank.insert(tileBank.end(), powerCleanedTilesMutated.begin(), powerCleanedTilesMutated.end());
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);

    // GENERATE NEW MUTATED DOT TILES (EATEN)
    // -------------------------------
    std::vector<tile> eatenMutatedDotTiles;
    for (int z = 0; z < 4; z++)     // UP TO 4 DOTS IN ONE TILE
    {
        for (const tile& t : tileBank) 
        {
            // FOR ALL 4 QUADRANTS
            for (int i = 0; i < 4; i++)
            {
                unsigned char mDotColorCount = 0;
                bool foundDot = false;
                const int *quadPtr = quadPtrs[i];

                // CHECK FOR DOT INDEXES
                for (int j = 0; j < 8; j++)
                {
                    int idx = quadPtr[j];
                    unsigned char lNibble = t.data[idx] & 0x0F;
                    unsigned char hNibble = (t.data[idx] & 0xF0) >> 4;

                    if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                        foundDot = true;
                    else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                        foundDot = true;
                    else if (lNibble == 2 && hNibble == 2)
                        mDotColorCount++;
                }
                // IF FOUND, REMOVE DOT AND ADD TO VECTOR
                if (foundDot == true || mDotColorCount == 2)
                {
                    tile blanked = blankoutQuad(t, i);
                    eatenMutatedDotTiles.push_back(blanked);
                }
            }
        }
        // Append modified tiles
        tileBank.insert(tileBank.end(), eatenMutatedDotTiles.begin(), eatenMutatedDotTiles.end());
    }
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);
    const int MDOT0_TABLE_SIZE = tileBank.size() - DOT_TABLE_SIZE;
    const int OTHER_TILE_START = tileBank.size();
    // -------------------------------
    #endif


    // ADD OTHER TILES
    // -------------------------------
    tileBank.insert(tileBank.end(), otherTiles.begin(), otherTiles.end());
        // REMOVE DUPLICATES
    removeDuplicates(tileBank);
    // -------------------------------
    // FINAL ORDER: ALL BLACK, DOT TILES, POW TILES, GENERATED TILES, OTHER


    // OUTPUT BMP
    // -------------------------------
    FILE *outBmp = fopen("TILE_MAZE.BMP", "wb");
    if (!outBmp) 
    {
        std::cerr << "Couldn't create TILE_MAZE.BMP!\n";
        return 1;
    }

    // WRITE HEADER
    fwrite(outHeader, 1, OUTHEADER_SIZE, outBmp);

    // IMAGE SETTINGS
    int tilesPerRow = 16;
    int tileWidthBytes = 4;         // 8 pixels (4bpp = 2 pixels per byte) = 4 bytes per row
    int tileHeight = 8;
    int tileStride = tileWidthBytes * tileHeight;  // 32 bytes per tile
    int totalTiles = tileBank.size();
    int totalRows = (totalTiles + tilesPerRow - 1) / tilesPerRow;

    // WRITE TILES
    std::vector<unsigned char> dataArr;
    dataArr.resize(totalRows * tileHeight * tilesPerRow * tileWidthBytes, 0);

    // WRITE TILES TO IMAGE BUFFER (bottom-up for BMP)
    for (int i = 0; i < totalTiles; i++) 
    {
        int tileX = i % tilesPerRow;
        int tileY = i / tilesPerRow;

        int flippedY = totalRows - 1 - tileY;  // BMP stores bottom-to-top

        for (int j = 0; j < tileHeight; j++) 
        {
            // Offset in image buffer
            int dstOffset = (flippedY * tileHeight + j) * (tilesPerRow * tileWidthBytes) + tileX * tileWidthBytes;
            memcpy(&dataArr[dstOffset], &tileBank[i].data[j * tileWidthBytes], tileWidthBytes);
        }
    }

    // WRITE IMAGE DATA
    fwrite(dataArr.data(), 1, dataArr.size(), outBmp);

    // UPDATE FILE SIZE
    int fileSize = OUTHEADER_SIZE + dataArr.size();
    fseek(outBmp, 0x0002, SEEK_SET);
    fwrite(&fileSize, sizeof(int), 1, outBmp);

    // UPDATE IMAGE HEIGHT
    int imageHeight = totalRows * tileHeight;
    fseek(outBmp, 0x0016, SEEK_SET);
    fwrite(&imageHeight, sizeof(int), 1, outBmp);

    fclose(outBmp);
    // -------------------------------


    // OUTPUT TILEMAP
    // -------------------------------
    std::vector<uint16_t> tilemap;

    uint16_t pDotNumber = 0x0000;
    uint8_t lastRowPDot = TILEY_COUNT-1;
    uint8_t lastColPDot = 0;
    for (int row = TILEY_COUNT-1; row >= 0; row--) {
        // MASKING TILES
        #if JR == 0
        tilemap.push_back(0x11FF);
        tilemap.push_back(0x11FF);
        #else
        //for (int i = 0; i < 5; i++) tilemap.push_back(0x11FF);
        #endif

        for (int col = 0; col < TILEX_COUNT; col++) {
            tile& inputTile = originalTileGrid[row * TILEX_COUNT + col];

            uint16_t word = 0;
            int matchedIndex = -1;
            bool hFlip = false;
            bool vFlip = false;

            for (int i = 0; i < tileBank.size(); i++) {
                if (tilesEqual(inputTile, tileBank[i])) {
                    matchedIndex = i;
                    break;
                }
                if (tilesEqual(inputTile, flipTileH(tileBank[i]))) {
                    matchedIndex = i;
                    hFlip = true;
                    break;
                }
                if (tilesEqual(inputTile, flipTileV(tileBank[i]))) {
                    matchedIndex = i;
                    vFlip = true;
                    break;
                }
                if (tilesEqual(inputTile, flipTileHV(tileBank[i]))) {
                    matchedIndex = i;
                    hFlip = vFlip = true;
                    break;
                }
            }

            if (matchedIndex == -1) {
                std::cerr << "Tile not found!\n";
                tilemap.push_back(0xFFFF);
                continue;
            }

            word = 0x100 | matchedIndex;
            if (hFlip) word |= 0x200;
            if (vFlip) word |= 0x400;

            #if JR == 0
            if (containsColor(inputTile, CLR_POW_0, CLR_POW_3)) {
                if (row >= 12 && col < 11)       word |= 0x0000; // Bit 13
                else if (row < 12 && col >= 11)  word |= 0x6000; // Bit 14
                else if (row >= 12 && col >= 11) word |= 0x4000; // Bits 13 + 14
                else                             word |= 0x2000;
                // Top-left: no extra bits
            }
            #else
            if (containsColor(inputTile, CLR_POW_0, CLR_POW_3)) {
                word |= pDotNumber;

                //if ((lastRowPDot - row) >= 2 || col - lastColPDot >= 2)
                //{
                    pDotNumber += 0x2000;
                //    lastRowPDot = row;
                //    lastColPDot = col;
               //}
            }
            #endif

            tilemap.push_back(word);
        }

        // MASKING TILES
        #if JR == 0
        for (int i = 0; i < 9; i++) tilemap.push_back(0x11FF);
        #else
        //for (int i = 0; i < 5; i++) tilemap.push_back(0x11FF);
        #endif
    }

    FILE* out = fopen("MAP_MAZE.BIN", "wb");
    if (!out) {
        std::cerr << "Couldn't create MAP_MAZE.BIN!\n";
        return 1;
    }
    fwrite(tilemap.data(), sizeof(uint16_t), tilemap.size(), out);
    fclose(out);
    // -------------------------------


    // WRITE DOT TABLE
    // -------------------------------
    FILE* dotFile = fopen("DOT_MAZE.BIN", "wb");
    if (!dotFile) {
        std::cerr << "Couldn't create DOT_MAZE.BIN!\n";
        return 1;
    }

    for (int t = 0; t < DOT_TABLE_SIZE; t++) {
        tile base = tileBank[t];
        unsigned char outBytes[4] = {0};


        // FOR ALL 4 QUADRANTS
        for (int i = 0; i < 4; i++)
        {
            bool foundDot = false, foundPower = false;
            const int *quadPtr = quadPtrs[i];

            // CHECK FOR DOT INDEXES OR POWER DOT INDEXES
            for (int j = 0; j < 8; j++)
            {
                int idx = quadPtr[j];
                unsigned char lNibble = base.data[idx] & 0x0F;
                unsigned char hNibble = (base.data[idx] & 0xF0) >> 4;

                 // DOT
                if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                    foundDot = true;
                else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                    foundDot = true;

                // POWER DOT
                if (lNibble >= CLR_POW_0)
                    foundPower = true;
                else if (hNibble >= CLR_POW_0)
                    foundPower = true;
            }


            tile blanked;
            if (foundDot == true)
            {
                // REMOVE DOT
                blanked = blankoutQuad(base, i);
            }
            else if (foundPower == true)
            {
                // REMOVE POWER DOT
                for (int idx = 0; idx < 32; idx++)
                {
                    unsigned char hNibb = (base.data[idx] & 0xF0) >> 4;
                    unsigned char lNibb = (base.data[idx] & 0x0F);

                    if (lNibb >= CLR_POW_0)
                        lNibb = 0;
                    if (hNibb >= CLR_POW_0)
                        hNibb = 0;

                    blanked.data[idx] = (hNibb << 4) | lNibb;
                }
            }

            if (foundDot == true || foundPower == true)
            {
                // FIND TILE THAT MATCHES
                int matchIdx = -1, h = 0, v = 0;
                if (findMatchingTileIndex(&blanked, tileBank, &matchIdx, &h, &v)) 
                {
                    unsigned char val = matchIdx & 0x3F;
                    if (h) val |= 0x40;
                    if (v) val |= 0x80;
                    outBytes[dotMatch[i]] = val;
                } 
                else 
                {
                    std::cerr << "COULDN'T FIND MATCH!/nDOT TABLE";
                    return 1;
                }
            }
        }
        fwrite(outBytes, 1, 4, dotFile);
    }

    fclose(dotFile);
    // -------------------------------

    // END HERE IF NOT ANALYZING A JR. MAZE
    #if JR == 1

    // WRITE MUTATED DOT TABLE (NORMAL TO MUTATED)
    // -------------------------------
    FILE* mDotFile = fopen("MDOT0_MAZE.BIN", "wb");
    if (!mDotFile) {
        std::cerr << "Couldn't create MDOT0_MAZE.BIN!\n";
        return 1;
    }

    // WRITE TILE OFFSET AS FIRST BYTE
    // WRITE UPPER BOUND AS SECOND BYTE
    unsigned char tileOffsetMDot[4] = {DOT_TABLE_SIZE, OTHER_TILE_START, 0, 0};
    fwrite(tileOffsetMDot, 1, 4, mDotFile);


    //for (int t = 1; t < DOT_TABLE_SIZE; t++) {
    for (int t = 1; t < (DOT_TABLE_SIZE + MDOT0_TABLE_SIZE); t++) {
        tile base = tileBank[t];
        unsigned char outBytes[4] = {0};


        // FOR ALL 4 QUADRANTS
        for (int i = 0; i < 4; i++)
        {
            bool foundDot = false;
            const int *quadPtr = quadPtrs[i];

            // CHECK FOR DOT INDEXES
            for (int j = 0; j < 8; j++)
            {
                int idx = quadPtr[j];
                unsigned char lNibble = base.data[idx] & 0x0F;
                unsigned char hNibble = (base.data[idx] & 0xF0) >> 4;

                 // DOT
                if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                    foundDot = true;
                else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                    foundDot = true;
                
            }

            if (foundDot == true)
            {
                tile blanked;
                // MUTATE DOT
                blanked = mutateQuad(base, i);
                // FIND TILE THAT MATCHES
                int matchIdx = -1, h = 0, v = 0;
                if (findMatchingTileIndex(&blanked, tileBank, &matchIdx, &h, &v)) 
                {
                    unsigned char val = matchIdx;
                    if (val != 0)
                        val = (matchIdx - DOT_TABLE_SIZE) & 0x3F;

                    if (h) val |= 0x40;
                    if (v) val |= 0x80;
                    outBytes[dotMatch[i]] = val;
                } 
                else 
                {
                    std::cerr << "COULDN'T FIND MATCH!\nMUTATED DOT NORMAL";
                    return 1;
                }
            }
        }
        fwrite(outBytes, 1, 4, mDotFile);
    }

    fclose(mDotFile);
    // -------------------------------

    


    
    // WRITE 2ND MUTATED DOT TABLE (MUTATED TO EATEN)
    // -------------------------------
    FILE* eatMDotFile = fopen("MDOT1_MAZE.BIN", "wb");
    if (!eatMDotFile) {
        std::cerr << "Couldn't create MDOT1_MAZE.BIN!\n";
        return 1;
    }

    for (int t = DOT_TABLE_SIZE; t < (DOT_TABLE_SIZE + MDOT0_TABLE_SIZE); t++) {
        tile base = tileBank[t];
        unsigned char outBytes[8] = {0};


        // FOR ALL 4 QUADRANTS
        for (int i = 0; i < 4; i++)
        {
            unsigned char mDotColorCount = 0;
            bool mDotFlag = false;
            bool foundDot = false;
            bool foundPower = false;
            const int *quadPtr = quadPtrs[i];

            // CHECK FOR DOT INDEXES OR POWER DOT INDEXES
            for (int j = 0; j < 8; j++)
            {
                int idx = quadPtr[j];
                unsigned char lNibble = base.data[idx] & 0x0F;
                unsigned char hNibble = (base.data[idx] & 0xF0) >> 4;

                 // DOT
                if (lNibble >= CLR_DOT_0 && lNibble <= CLR_DOT_2)
                    foundDot = true;
                else if (hNibble >= CLR_DOT_0 && hNibble <= CLR_DOT_2)
                    foundDot = true;
                // MUTATED DOT
                else if (lNibble == 2 && hNibble == 2)
                    mDotColorCount++;
                // POWER DOT
                if (lNibble >= CLR_POW_0)
                    foundPower = true;
                else if (hNibble >= CLR_POW_0)
                    foundPower = true;
            }

            if (mDotColorCount == 2)
            {
                foundDot = true;
                mDotFlag = true;
            }

            tile blanked;
            if (foundDot == true)
            {
                // REMOVE DOT
                blanked = blankoutQuad(base, i);
            }
            else if (foundPower == true)
            {
                // REMOVE POWER DOT
                for (int idx = 0; idx < 32; idx++)
                {
                    unsigned char hNibb = (base.data[idx] & 0xF0) >> 4;
                    unsigned char lNibb = (base.data[idx] & 0x0F);

                    if (lNibb >= CLR_POW_0)
                        lNibb = 0;
                    if (hNibb >= CLR_POW_0)
                        hNibb = 0;

                    blanked.data[idx] = (hNibb << 4) | lNibb;
                }
            }

            if (foundDot == true || foundPower == true)
            {
                /*
                tile blanked;
                // BLANK DOT
                blanked = blankoutQuad(base, i);
                */
                // FIND TILE THAT MATCHES
                int matchIdx = -1, h = 0, v = 0;
                if (findMatchingTileIndex(&blanked, tileBank, &matchIdx, &h, &v)) 
                {
                    outBytes[dotMatch[i] * 2] = matchIdx;

                    unsigned char val = 0x00;
                    if (h) val |= 0x02;
                    if (v) val |= 0x04;
                    if (mDotFlag) val |= 0x80;

                    outBytes[dotMatch[i] * 2 + 1] = val;
                } 
                else 
                {
                    std::cerr << "COULDN'T FIND MATCH!\nMUTATED DOT EATEN";
                    return 1;
                }
            }
            else 
            {
                outBytes[dotMatch[i] * 2] = 0xFF;
            }
        }
        fwrite(outBytes, 1, 8, eatMDotFile);
    }

    fclose(eatMDotFile);
    // -------------------------------





    // WRITE 3RD MUTATED DOT TABLE (MUTATED TO NORMAL)
    // -------------------------------
    FILE* normMDotFile = fopen("MDOT2_MAZE.BIN", "wb");
    if (!normMDotFile) {
        std::cerr << "Couldn't create MDOT2_MAZE.BIN!\n";
        return 1;
    }

    // WRITE UPPER BOUND WHERE NON DOT MAZE TILES START
    for (int t = DOT_TABLE_SIZE; t < (DOT_TABLE_SIZE + MDOT0_TABLE_SIZE); t++) {
        tile base = tileBank[t];
        unsigned char outByte = 0;


        tile normal;
        // BLANK DOT
        normal = mutateToNormal(base);
        // FIND TILE THAT MATCHES
        int matchIdx = -1, h = 0, v = 0;
        if (findMatchingTileIndex(&normal, tileBank, &matchIdx, &h, &v)) 
        {
            outByte = matchIdx;
        } 
        else 
        {
            std::cerr << "COULDN'T FIND MATCH!\nMUTATED DOT TO NORMAL";
            return 1;
        }
        fwrite(&outByte, 1, 1, normMDotFile);
    }

    fclose(normMDotFile);
    // -------------------------------
    #endif




    return 0;
}