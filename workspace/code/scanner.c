#include "scanner.h"

int read_mission(FILE *input, Mission *mission)
{
    return fscanf(input, "%31s %d %d %d %d",
                  mission->sector,
                  &mission->distance,
                  &mission->jump_cost,
                  &mission->risk,
                  &mission->available_fuel) == 5;
}
