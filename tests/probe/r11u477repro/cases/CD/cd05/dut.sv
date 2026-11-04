// § parenCallWrittenArgs477
class obj;
  task put(obj rhs, int n = 3);
  endtask
endclass
class comp #(type T = obj);
  T exp;
  task run(T rec);
    exp.put(rec);
  endtask
endclass
module top;
endmodule
