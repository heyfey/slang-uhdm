// § naArrNetOwnPortDecl155v
typedef struct packed { logic [5:0] third; } struct2;
module dut(var3);
  output var3;
  struct2 var3 [3];
  for (genvar i=0; i<3; i++) begin : g
    assign var3[i] = struct2'(127);
  end
endmodule
