#ifndef IDEVICE_H
#define IDEVICE_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/socket.h>
#include "plist.h"

#define LOCKDOWN_PORT 62078

// 声明idevice库中的主要类型和函数，但不实现它们
// 我们将链接到libidevice_ffi.a库

typedef enum IdeviceLogLevel {
  Disabled = 0,
  ErrorLevel = 1,
  Warn = 2,
  Info = 3,
  Debug = 4,
  Trace = 5,
} IdeviceLogLevel;

typedef struct IdeviceFfiError {
  int32_t code;
  const char *message;
} IdeviceFfiError;

typedef struct AdapterHandle AdapterHandle;
typedef struct AdapterStreamHandle AdapterStreamHandle;
typedef struct DebugProxyHandle DebugProxyHandle;
typedef struct HeartbeatClientHandle HeartbeatClientHandle;
typedef struct IdeviceHandle IdeviceHandle;
typedef struct IdevicePairingFile IdevicePairingFile;
typedef struct IdeviceProviderHandle IdeviceProviderHandle;
typedef struct ProcessControlHandle ProcessControlHandle;
typedef struct ReadWriteOpaque ReadWriteOpaque;
typedef struct RemoteServerHandle RemoteServerHandle;
typedef struct RsdHandshakeHandle RsdHandshakeHandle;

// 函数声明
struct IdeviceFfiError *idevice_new(struct IdeviceSocketHandle *socket,
                                    const char *label,
                                    struct IdeviceHandle **idevice);

struct IdeviceFfiError *idevice_new_tcp_socket(const struct sockaddr *addr,
                                               socklen_t addr_len,
                                               const char *label,
                                               struct IdeviceHandle **idevice);

struct IdeviceFfiError *idevice_get_type(struct IdeviceHandle *idevice,
                                         char **device_type);

struct IdeviceFfiError *idevice_rsd_checkin(struct IdeviceHandle *idevice);

struct IdeviceFfiError *idevice_start_session(struct IdeviceHandle *idevice,
                                              const struct IdevicePairingFile *pairing_file);

void idevice_free(struct IdeviceHandle *idevice);
void idevice_string_free(char *string);

struct IdeviceFfiError *adapter_connect(struct AdapterHandle *adapter_handle,
                                        uint16_t port,
                                        struct ReadWriteOpaque **stream_handle);

struct IdeviceFfiError *adapter_close(struct AdapterStreamHandle *handle);

struct IdeviceFfiError *debug_proxy_connect_rsd(struct AdapterHandle *provider,
                                                struct RsdHandshakeHandle *handshake,
                                                struct DebugProxyHandle **handle);

void debug_proxy_free(struct DebugProxyHandle *handle);

struct IdeviceFfiError *debug_proxy_send_command(struct DebugProxyHandle *handle,
                                                 struct DebugserverCommandHandle *command,
                                                 char **response);

struct IdeviceFfiError *debug_proxy_send_raw(struct DebugProxyHandle *handle,
                                             const uint8_t *data,
                                             uintptr_t len);

struct IdeviceFfiError *debug_proxy_send_ack(struct DebugProxyHandle *handle);

void debug_proxy_set_ack_mode(struct DebugProxyHandle *handle, int enabled);

struct IdeviceFfiError *heartbeat_connect(struct IdeviceProviderHandle *provider,
                                          struct HeartbeatClientHandle **client);

struct IdeviceFfiError *heartbeat_send_polo(struct HeartbeatClientHandle *client);

struct IdeviceFfiError *heartbeat_get_marco(struct HeartbeatClientHandle *client,
                                            uint64_t interval,
                                            uint64_t *new_interval);

void heartbeat_client_free(struct HeartbeatClientHandle *handle);

struct IdeviceFfiError *process_control_new(struct RemoteServerHandle *server,
                                            struct ProcessControlHandle **handle);

void process_control_free(struct ProcessControlHandle *handle);

struct IdeviceFfiError *process_control_launch_app(struct ProcessControlHandle *handle,
                                                   const char *bundle_id,
                                                   const char *const *env_vars,
                                                   uintptr_t env_vars_count,
                                                   const char *const *arguments,
                                                   uintptr_t arguments_count,
                                                   bool start_suspended,
                                                   bool kill_existing,
                                                   uint64_t *pid);

struct IdeviceFfiError *process_control_kill_app(struct ProcessControlHandle *handle, uint64_t pid);

struct IdeviceFfiError *process_control_disable_memory_limit(struct ProcessControlHandle *handle,
                                                             uint64_t pid);

struct IdeviceFfiError *idevice_tcp_provider_new(const struct sockaddr *ip,
                                                 struct IdevicePairingFile *pairing_file,
                                                 const char *label,
                                                 struct IdeviceProviderHandle **provider);

void idevice_provider_free(struct IdeviceProviderHandle *provider);

struct IdeviceFfiError *remote_server_connect_rsd(struct AdapterHandle *provider,
                                                  struct RsdHandshakeHandle *handshake,
                                                  struct RemoteServerHandle **handle);

void remote_server_free(struct RemoteServerHandle *handle);

struct IdeviceFfiError *rsd_handshake_new(struct ReadWriteOpaque *socket,
                                          struct RsdHandshakeHandle **handle);

void rsd_handshake_free(struct RsdHandshakeHandle *handle);

void idevice_error_free(struct IdeviceFfiError *err);

enum IdeviceLoggerError idevice_init_logger(enum IdeviceLogLevel console_level,
                                            enum IdeviceLogLevel file_level,
                                            char *file_path);

struct IdeviceFfiError *idevice_pairing_file_read(const char *path,
                                                  struct IdevicePairingFile **pairing_file);

void idevice_pairing_file_free(struct IdevicePairingFile *pairing_file);

#endif /* IDEVICE_H */