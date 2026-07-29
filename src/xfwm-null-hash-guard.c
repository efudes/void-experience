/*
 * Runtime equivalent of upstream xfwm4 commit 69a16352:
 * return NULL when an external compositor makes compositorIsActive() true
 * while xfwm4's own cwindow_hash has not been allocated.
 *
 * This library is loaded only by the user-local XFCE xfwm4 wrapper.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stddef.h>

typedef void *(*hash_lookup_fn)(void *, const void *);

void *
g_hash_table_lookup(void *hash_table, const void *key)
{
    static hash_lookup_fn real_lookup;

    if (hash_table == NULL)
    {
        return NULL;
    }

    if (real_lookup == NULL)
    {
        real_lookup = (hash_lookup_fn) dlsym(RTLD_NEXT,
                                             "g_hash_table_lookup");
    }

    return real_lookup != NULL ? real_lookup(hash_table, key) : NULL;
}
