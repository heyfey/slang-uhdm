// § castUnionCloneFile171
package p;
  typedef union packed {
    logic [7:0] w;
    struct packed { logic [3:0] hi; logic [3:0] lo; } f;
  } u_t;
endpackage
