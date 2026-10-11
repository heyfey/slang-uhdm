// § withCallParenSyntax286 — class task: parenthesized with-calls in operand, whole rhs, double parens, if condition
package p;
  class c;
    int q[$];
    task t;
      int r;
      r = q.sum() with ( item );
      r = 1 + (q.sum() with ( item ));
      r = (q.sum() with ( item ));
      r = ((q.sum() with ( item )));
      if ((q.sum() with ( item )) > 0) r = 1;
      r = 1 + (q.sum() with (item));
      r = 1 + q.sum() with ( item );
    endtask
  endclass
endpackage
module top; import p::*; endmodule
