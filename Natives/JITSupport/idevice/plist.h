#ifndef LIBPLIST_H
#define LIBPLIST_H

#ifdef __cplusplus
extern "C"
{
#endif

#if _MSC_VER && _MSC_VER < 1700
    typedef __int8 int8_t;
    typedef __int16 int16_t;
    typedef __int32 int32_t;
    typedef __int64 int64_t;

    typedef unsigned __int8 uint8_t;
    typedef unsigned __int16 uint16_t;
    typedef unsigned __int32 uint32_t;
    typedef unsigned __int64 uint64_t;

#else
#include <stdint.h>
#endif

#include <sys/types.h>
#include <stdarg.h>

// 声明plist库中的主要类型和函数，但不实现它们
// 我们将链接到libplist-2.0.a库

typedef void *plist_t;
typedef void* plist_dict_iter;
typedef void* plist_array_iter;

typedef enum
{
    PLIST_BOOLEAN,  
    PLIST_INT,      
    PLIST_REAL,     
    PLIST_STRING,   
    PLIST_ARRAY,    
    PLIST_DICT,     
    PLIST_DATE,     
    PLIST_DATA,     
    PLIST_KEY,      
    PLIST_UID,      
    PLIST_NULL,     
    PLIST_NONE      
} plist_type;

plist_t plist_new_dict(void);
plist_t plist_new_array(void);
plist_t plist_new_string(const char *val);
plist_t plist_new_bool(uint8_t val);
plist_t plist_new_uint(uint64_t val);
plist_t plist_new_int(int64_t val);
plist_t plist_new_real(double val);
plist_t plist_new_data(const char *val, uint64_t length);
plist_t plist_new_date(int32_t sec, int32_t usec);
plist_t plist_new_uid(uint64_t val);
plist_t plist_new_null(void);
void plist_free(plist_t plist);
plist_t plist_copy(plist_t node);

// 更多plist函数声明...
uint32_t plist_array_get_size(plist_t node);
plist_t plist_array_get_item(plist_t node, uint32_t n);
void plist_array_set_item(plist_t node, plist_t item, uint32_t n);
void plist_array_append_item(plist_t node, plist_t item);
void plist_array_insert_item(plist_t node, plist_t item, uint32_t n);
void plist_array_remove_item(plist_t node, uint32_t n);

uint32_t plist_dict_get_size(plist_t node);
plist_t plist_dict_get_item(plist_t node, const char* key);
void plist_dict_set_item(plist_t node, const char* key, plist_t item);

void plist_get_string_val(plist_t node, char **val);
void plist_get_bool_val(plist_t node, uint8_t * val);
void plist_get_uint_val(plist_t node, uint64_t * val);
void plist_get_int_val(plist_t node, int64_t * val);
void plist_get_real_val(plist_t node, double *val);
void plist_get_data_val(plist_t node, char **val, uint64_t * length);
void plist_get_date_val(plist_t node, int32_t * sec, int32_t * usec);
void plist_get_uid_val(plist_t node, uint64_t * val);

void plist_set_string_val(plist_t node, const char *val);
void plist_set_bool_val(plist_t node, uint8_t val);
void plist_set_uint_val(plist_t node, uint64_t val);
void plist_set_int_val(plist_t node, int64_t val);
void plist_set_real_val(plist_t node, double val);
void plist_set_data_val(plist_t node, const char *val, uint64_t length);
void plist_set_date_val(plist_t node, int32_t sec, int32_t usec);
void plist_set_uid_val(plist_t node, uint64_t val);

#ifdef __cplusplus
}
#endif
#endif