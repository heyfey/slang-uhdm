// § importCloneBodyLocalCopies175
package p1;
  typedef struct { int a; int b; } s_t;
  task automatic t(output int o);
    s_t st = '{a:1, b:2};
    int arr [3] = '{default:0};
    o = st.a + arr[2];
  endtask
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
  import p2::*;
endpackage
module top; int r; initial p1::t(r); endmodule
