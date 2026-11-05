// two module functions, the module later in the file sorts first by name
package zp;
  typedef logic [7:0] zb_t;
endpackage
module mb;
  function int bf (zp::zb_t a);
    return int'(a);
  endfunction
  int r;
  initial r = bf(8'h1);
endmodule
module ma;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
  int r;
  mb u ();
  initial r = af(8'h1);
endmodule
