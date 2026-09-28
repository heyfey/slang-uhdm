// § lvIdxCallArgIsRead198
`define ARGSEL(v, i) v.f[i]
`define LVIDX(a, v, i) a[fx(`ARGSEL(v, i))]
