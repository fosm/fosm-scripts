#include <stdio.h>
#include "gtmxc_types.h"
#include <termios.h>

#define BUF_LEN 1024
int main(int argc, char *argv[])
{
        gtm_char_t      port[] = "6520";
        gtm_char_t      logLevel[] = "0";
        gtm_char_t      process[100];
        gtm_char_t      msgbuf[BUF_LEN];
        gtm_status_t    status;
        struct termios stderr_sav;
        struct termios stdin_sav;
        struct termios stdout_sav;

        tcgetattr( 0, &stdin_sav );
        tcgetattr( 1, &stdout_sav );
        tcgetattr( 2, &stderr_sav );

        status = gtm_init();
        if (status != 0)
        {
            gtm_zstatus(msgbuf, BUF_LEN);

            // Restore original parameters
            tcsetattr( 2, 0, &stderr_sav );
            tcsetattr( 1, 0, &stdout_sav );
            tcsetattr( 0, 0, &stdin_sav );
            return status;
        }
        status = gtm_ci("xapi", argv[1], argv[2], argv[3]);
        if (status != 0)
        {
            gtm_zstatus(msgbuf, BUF_LEN);
            fprintf(stderr, "%s\n", msgbuf);
            tcsetattr( 2, 0, &stderr_sav );
            tcsetattr( 1, 0, &stdout_sav );
            tcsetattr( 0, 0, &stdin_sav );
            return status;
        }
        tcsetattr( 2, 0, &stderr_sav );
        tcsetattr( 1, 0, &stdout_sav );
        tcsetattr( 0, 0, &stdin_sav );
        return 0;
}
