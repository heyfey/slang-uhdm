module mv6b;
  integer mi;
  initial begin : b6
    automatic logic   f_vlauto = 1'b1;
    automatic integer g_intauto = 1;
    integer           h_intplain = 2;
    mi = g_intauto + h_intplain;
  end
endmodule
