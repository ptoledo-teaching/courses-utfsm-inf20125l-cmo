#ifndef MISSION_H
#define MISSION_H

#define MAX_SECTOR_NAME 32

typedef struct
{
    char sector[MAX_SECTOR_NAME];
    int distance;
    int jump_cost;
    int risk;
    int available_fuel;
} Mission;

typedef struct
{
    Mission mission;
    int required_fuel;
    int margin;
    int approved;
} MissionResult;

#endif
