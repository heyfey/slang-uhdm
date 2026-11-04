// § tfFormalTdCloneFile196: control, the typedef and its formals in one file (the file does not change), an int typedef
package p;
  typedef logic [3:0] it_t;
  typedef int unsigned cnt_t;
  function automatic int g(input it_t v, cnt_t c);
    return v + c;
  endfunction
endpackage
module top;
endmodule
