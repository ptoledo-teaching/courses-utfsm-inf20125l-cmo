#ifndef NAVIGATION_H
#define NAVIGATION_H

#include "mission.h"

extern const int NAVIGATION_PROTOCOL_VERSION;

MissionResult evaluate_mission(const Mission *mission);

#endif
