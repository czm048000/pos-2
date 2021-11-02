#ifndef POS_KERN_PANIC_H
#define POS_KERN_PANIC_H

void
_panic(const char *file, int line, const char *fmt,...);

void
_warn(const char *file, int line, const char *fmt,...);

#endif