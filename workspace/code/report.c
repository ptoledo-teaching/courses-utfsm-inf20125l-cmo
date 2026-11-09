#include <stdio.h>

#include "report.h"

void print_result(int index, const MissionResult *result)
{
    printf("Mision %03d: %s | sector=%s | combustible=%d/%d | margen=%d\n",
           index,
           result->approved ? "APROBADA" : "RECHAZADA",
           result->mission.sector,
           result->required_fuel,
           result->mission.available_fuel,
           result->margin);
}
