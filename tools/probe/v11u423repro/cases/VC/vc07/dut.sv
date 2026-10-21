// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::A;
import p::f_t;
class C;
  task t(f_t x, output bit o);
    begin
      case (x)
        A: o = 1;
        default: o = (x & A) == 0;
      endcase
    end
  endtask
endclass
module top; C c; endmodule
