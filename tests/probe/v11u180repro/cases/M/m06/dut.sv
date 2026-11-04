// § modAggTfArgCloneFollows180 (verifier: an INTERFACE typedef moved by an interface function formal, copy in a localparam)
interface bus_if;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } op_t;
  localparam op_t P = '{a: 4'h1, b: 4'h2};
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
  logic [7:0] o;
  assign o = f(P);
endinterface
module top(output logic [7:0] y);
  bus_if b();
  assign y = b.o;
endmodule
