// § parenCallWrittenArgs477
class obj;
  function bit compare(obj rhs, obj c = null);
    return 1;
  endfunction
endclass
module top;
  obj exp, rec;
  bit b;
  initial b = (exp.compare(rec));
endmodule
