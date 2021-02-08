/*
 *
 * OSK key retrieval utility 
 *
 * Inspired by:
 *   https://web.archive.org/web/20200603015401/http://www.osxbook.com/book/bonus/chapter7/tpmdrmmyth/
 *   https://opensource.apple.com/source/PowerManagement/PowerManagement-211/pmconfigd/PrivateLib.c
 *
 * > IOKit framework required
 *
 * Author: Vladislav Yaroshchuk <yaroshchuk2000@gmail.com>
 */

#include <stdio.h>
#include <stdlib.h>

#include <IOKit/IOKitLib.h>

#define SMC_CLIENT_OPEN       0
#define SMC_CLIENT_CLOSE      1
#define SMC_HANDLE_YPC_EVENT  2
#define SMC_READ_KEY          5

#define OSK0_KEY ('OSK0')
#define OSK1_KEY ('OSK1')

typedef struct {
    IOByteCount         data_size;
    uint32_t            data_type;
    uint8_t             data_attr;
} smc_key_info_t;

typedef struct {
    uint32_t            key;
    uint8_t             __unused_vers[6];
    uint8_t             __unused_plimit[16];
    smc_key_info_t      key_info;
    uint8_t             result;
    uint8_t             status;
    uint8_t             command;
    uint32_t            data32;
    uint8_t             bytes[32];
} smc_param_t;

static IOReturn rdsmc(smc_param_t *in, smc_param_t *out) {
  size_t        out_size;
  io_service_t  smc;
  io_connect_t  smc_connect;
  IOReturn      status;

  out_size = sizeof(*out);
  
  smc = IO_OBJECT_NULL;
  smc_connect = IO_OBJECT_NULL;
  status = kIOReturnError;
  
  smc = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSMC"));
  if (smc == IO_OBJECT_NULL) {
    fprintf(stderr, "AppleSMC service is unreachable\n");
    return kIOReturnNotFound;
  }

  status = IOServiceOpen(smc, mach_task_self(), 1, &smc_connect);
  if (status != kIOReturnSuccess || smc_connect == IO_OBJECT_NULL) {
    fprintf(stderr, "IOServiceOpen failed\n");
    return status;
  }

  status = IOConnectCallMethod(
    smc_connect, 
    SMC_CLIENT_OPEN,
    NULL, 0, NULL, 0, NULL, NULL, NULL, NULL
    );
  
  if (status == kIOReturnSuccess) {
    status = IOConnectCallStructMethod(
      smc_connect, SMC_HANDLE_YPC_EVENT,
      in, sizeof(*in),
      out, &out_size
      );
  } else {
    fprintf(stderr, "IO Client Open failed\n");
  }

  IOConnectCallMethod(
    smc_connect, 
    SMC_CLIENT_CLOSE,
    NULL, 0, NULL, 0, NULL, NULL, NULL, NULL);
  IOServiceClose(smc_connect);

  return status;
}

int main(void) {
  IOReturn     status;
  smc_param_t  in = {0};
  smc_param_t  out = {0};
  int          i; 
  
  status = kIOReturnError;
  in.key = OSK0_KEY;
  in.key_info.data_size = sizeof(out.bytes);
  in.command = SMC_READ_KEY;
  
  status = rdsmc(&in, &out);
  if (status != kIOReturnSuccess) {
    fprintf(stderr, "Unable to read OSK0\n");
    return -1;
  }  


  for (i = 0; i < sizeof(out.bytes); ++i) {
    fprintf(stdout, "%c", out.bytes[i]);
  }

  in.key = OSK1_KEY;
  status = rdsmc(&in, &out);
  if (status != kIOReturnSuccess) {
    fprintf(stderr, "Unable to read OSK1\n");
    return -1;
  }  


  for (i = 0; i < sizeof(out.bytes); ++i) {
    fprintf(stdout, "%c", out.bytes[i]);
  }

  return 0;
}

