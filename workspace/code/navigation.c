#include "navigation.h"

const int NAVIGATION_PROTOCOL_VERSION = 12;

static int risk_penalty(int risk)
{
    return risk * 25;
}

MissionResult evaluate_mission(const Mission *mission)
{
    MissionResult result;

    result.mission = *mission;
    result.required_fuel = mission->distance * mission->jump_cost + risk_penalty(mission->risk);
    result.margin = mission->available_fuel - result.required_fuel;
    result.approved = result.margin >= 0;

    return result;
}
