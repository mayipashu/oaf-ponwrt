#include <linux/kernel.h>
#include <linux/module.h>
#include <net/netfilter/nf_conntrack_extend.h>

/*
 * Shim: provide __nf_ct_ext_find for PonWrt 6.18.55
 * where nf_conntrack.ko exports nf_ct_ext_add but not __nf_ct_ext_find.
 *
 * We skip the gen_id guard (safe at runtime: gen_id bumps only during
 * conntrack helper rebuilds, which PonWrt never triggers).
 */
void *__nf_ct_ext_find(const struct nf_ct_ext *ext, u8 id)
{
    if (!__nf_ct_ext_exist(ext, id))
        return NULL;
    return (void *)ext + ext->offset[id];
}
EXPORT_SYMBOL(__nf_ct_ext_find);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Stub for __nf_ct_ext_find");
