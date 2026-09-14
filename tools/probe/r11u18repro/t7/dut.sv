// t7: a class with BOTH written forms, SPECIALIZED -- the class_typespec's own
// parameter listing (emitClassTsParams / the explicit `#(...)` arm).
class cls #(parameter type CT = int, localparam type CLT = byte);
  CT a; CLT b;
  function int f(); return 0; endfunction
endclass
class user;
  cls #(logic [3:0]) h;
  cls #(int)         g;
  function int f(); return 0; endfunction
endclass
module dut(output logic o);
  assign o = 1'b0;
endmodule
