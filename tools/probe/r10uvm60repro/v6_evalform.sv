// VERIFIER ARM v6 — the PRODUCT CELL the grid skipped:
//   (body IS evaluated)  x  (form of the written literal)
// b3_actual.sv varied the literal ONLY in bodies nothing evaluates, where
// golden is bare for every form; b6_reached.sv varied the REACH but held the
// literal at a bare `1`.  The stamping/resizing half of the landed `if` still
// fires for evaluated bodies, so the question "does golden resize EVERY literal
// form to the formal width, or only the unsized decimal?" is untested.
// Every row below sits in a body that IS a continuous-assign rhs callee.
module v6_evalform(input logic [3:0] inp, output logic [7:0] o);

   function automatic logic [3:0] g4(logic [3:0] v);   return v; endfunction
   function automatic logic [7:0] g8(logic [7:0] v);   return v; endfunction
   function automatic int         gi(int v);           return v; endfunction
   function automatic string      gs(string v);        return "x"; endfunction

   function automatic logic [7:0] ev(logic [3:0] x);
      logic [7:0] acc;
      acc  = 8'(g4(1));        // unsized decimal on a 4-bit formal
      acc += 8'(g4(1'b1));     // sized binary
      acc += 8'(g4(4'd3));     // sized decimal, exact formal width
      acc += 8'(g4('1));       // unbased unsized
      acc += 8'(g8(8'hAB));    // sized hex on an 8-bit formal
      acc += 8'(g8(3'b101));   // NARROWER than the formal
      acc += 8'(gi(7));        // unsized decimal on an int formal
      acc += 8'(gi(-2));       // negative
      acc += (gs("s") == "x") ? 8'd1 : 8'd0;   // string actual
      return acc + x;
   endfunction

   assign o = ev(inp);
endmodule
