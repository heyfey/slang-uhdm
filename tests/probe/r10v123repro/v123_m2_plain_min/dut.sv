// r10v123 minimal M2 — the CONTROL: the same shape with a PLAIN bit typedef.
package peach123_pkg;
  typedef bit [7:0] peach_v_t;
  function automatic int peach_f(int qq);
    peach_v_t mm;
    mm = peach_v_t'(qq);
    return int'(mm);
  endfunction
endpackage
module peach_top;
  int rr;
  initial rr = peach123_pkg::peach_f(3);
endmodule
