// § classRetFillUnsized433
class B;
  virtual function logic [3:0] g();
    return '1;
  endfunction
endclass
class D extends B;
  function logic [3:0] g();
    return '0;
  endfunction
  static function bit [1:0] s();
    return '1;
  endfunction
endclass
module top; endmodule
