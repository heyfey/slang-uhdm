// § modAggTfArgCloneFollows180
interface bus_if;
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  op_t d;
  function automatic logic [11:0] g (op_t op); g = op.f; endfunction
endinterface
module top (output logic [11:0] o);
  bus_if b();
  assign o = b.g(b.d);
endmodule
