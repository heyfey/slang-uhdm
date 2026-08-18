// vrgg17 v2 — TAIL-SHAPE axis incl. MEMBER-OF-MEMBER (3 path components).
typedef struct packed { logic [31:0] f; logic [31:0] g; } inner_t;
interface sif;
  logic [31:0] value;
  inner_t s;
  logic [31:0] m [0:3];
endinterface
module sink  (input logic [3:0] d); endmodule
module sink1 (input logic d); endmodule
module sink32(input logic [31:0] d); endmodule
module top;
  sif arr[20]();
  for (genvar i = 0; i < 2; i++) begin : g
    sink   u_w1 (.d(arr[2+3*i].s.f[0+:4]));    // member-of-member, ips tail
    sink   u_w2 (.d(arr[2+3*i].s.f[3:0]));     // member-of-member, range tail
    sink32 u_w3 (.d(arr[2+3*i].s.f));          // member-of-member, plain tail
    sink1  u_w4 (.d(arr[2+3*i].s.f[3]));       // member-of-member, bit tail
    sink   u_w5 (.d(arr[2+3*i].m[1][0+:4]));   // mid+tail both indexed
    sink   u_w6 (.d(arr[2+3*i].m[i][0+:4]));   // mid indexed by GENVAR
    sink   u_w7 (.d(arr[2+3*i].s.g[0+:4]));    // second member
  end
endmodule
