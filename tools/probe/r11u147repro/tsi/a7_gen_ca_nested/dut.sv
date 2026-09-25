// § ifaceMemberTrailIdxNamesByPath147
interface bus_if;
  typedef struct packed { logic [3:0] arr; } req_t;
  req_t req;
endinterface
module child (bus_if sub, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i] = sub.req.arr[i];
  end
endmodule
module top (input logic [3:0] ben_i, output logic [3:0] o);
  bus_if sub ();
  assign sub.req.arr = ben_i;
  child c (.sub(sub), .o(o));
endmodule
