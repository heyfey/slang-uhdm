// § methodSpanSkipsAttrs144
module dut;
  class c;
    (* keep *)
    protected function int f();
      return 3;
    endfunction
  endclass
endmodule
