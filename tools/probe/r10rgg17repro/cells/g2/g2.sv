// r10rgg17 grid g2 — the BASE KIND axis and the DIRECTION axis.
//  * an interface array declared DESCENDING (r10vrgg14's slot trap)
//  * a MODULE-instance array element as the path base
//  * an unpacked VARIABLE array of structs as the path base
//  * a MODULE-SCOPE instantiation (no gen scope) — must NOT move
interface sif;
  logic [31:0] value;
endinterface

module sink (input logic [3:0] d);
endmodule

typedef struct packed { logic [31:0] f; } st_t;

module top;
  sif dn[20:10]();          // DESCENDING
  sif up[0:19]();           // ASCENDING, explicit
  st_t sarr[0:19];

  // MODULE SCOPE: no generate block at all.
  sink u_m1 (.d(up[3].value[0+:4]));

  for (genvar i = 0; i < 2; i++) begin : g
    // descending array, arithmetic index
    sink u_b1 (.d(dn[12+2*i].value[0+:4]));
    // descending array, bare genvar
    sink u_b2 (.d(dn[10+i].value[0+:4]));
    // ascending explicit-range array
    sink u_b3 (.d(up[12+2*i].value[0+:4]));
    // an unpacked VARIABLE array of structs (not an instance array)
    sink u_b4 (.d(sarr[2+3*i].f[0+:4]));
  end
endmodule
