// § ifaceMemberTrailIdxNamesByPath147
typedef struct packed { logic [3:0] arr; logic v; } req_t;
interface bus_if;
  req_t req;
endinterface
module child (bus_if sub, input logic [1:0] i, output logic o);
  always_comb o = sub.req.arr[i];
endmodule
module top (input req_t r, input logic [1:0] i, output logic o);
  bus_if sub ();
  assign sub.req = r;
  child c (.sub(sub), .i(i), .o(o));
endmodule
