#include <iostream>
#include <algorithm>
#include <sstream>
#include <filesystem>
#include <unistd.h>

#include "zip.h"

#define APPLICATION_NAME "Game.exe"

int on_extract_entry(const char *filename, void *arg) {
    return 0;
}

int main(int argc, char* argv[]) {
    char* path = argv[1];
    if (!std::filesystem::exists(path))
        return 1; // update file not found
    std::cout << "Found update.rfa at " << path << std::endl;
    sleep(2); // wait for the game to shut down. a bit janky i might replace this with something that checks for a running process
    zip_extract(path, "./", on_extract_entry, NULL);
    char cmd[256];
    sprintf(cmd, "start %s", APPLICATION_NAME); // windows only!
    std::cout << "Launching " << APPLICATION_NAME << std::endl;
    system(cmd);
}