// r10earl29 VERIFIER arm v8 — the remaining CONTEXT axis the brief names for a
// NAME law: an EVENT CONTROL, a CASE expression, a PORT connection, a call
// ARGUMENT and an INSIDE/ternary condition.  Each is a different statement
// position that could reach a different hier_path producer.
module v8_sub (
    input  logic a,
    output logic y
);
  assign y = a;
endmodule
module v8_sites2 (
    input  logic       clk,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  st_t  q;
  logic [3:0] k;
  logic       sy;
  v8_sub u (.a(q.autoexecprogbuf[{1'b1, k[0]}]), .y(sy));  // PORT connection
  function automatic logic fz(input logic x);
    return x;
  endfunction
  always @(posedge q.autoexecprogbuf[{1'b1, k[0]}]) begin  // EVENT CONTROL
    o1 <= 1'b1;
  end
  always_comb begin
    case (q.autoexecprogbuf[{1'b1, k[1]}])                 // CASE expression
      1'b0: o2 = 1'b0;
      default: o2 = 1'b1;
    endcase
    o3 = fz(q.autoexecprogbuf[{1'b1, k[2]}]);              // call ARGUMENT
    o4 = sy;
  end
endmodule
