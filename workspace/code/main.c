#include <stdio.h>

#include "navigation.h"
#include "report.h"
#include "scanner.h"

int main(void)
{
    int mission_count = 0;

    if (scanf("%d", &mission_count) != 1)
    {
        fprintf(stderr, "Error: no se pudo leer la cantidad de misiones.\n");
        return 1;
    }

    printf("Protocolo de navegacion: %d\n", NAVIGATION_PROTOCOL_VERSION);

    for (int i = 1; i <= mission_count; i++)
    {
        Mission mission;

        if (!read_mission(stdin, &mission))
        {
            fprintf(stderr, "Error: solicitud incompleta en la mision %d.\n", i);
            return 1;
        }

        MissionResult result = evaluate_mission(&mission);
        print_result(i, &result);
    }

    return 0;
}
