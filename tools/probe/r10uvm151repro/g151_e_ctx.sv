// r10uvm151 arm E — CONTEXTS.  The law is gated on STATEMENT POSITION alone,
// so this arm walks the same `q.sort() with (item)` through every statement
// container a body can nest it in — including the `fork begin` the corpus head
// itself sits in (uvm-1.2 `base/uvm_component.svh:3433-3436`) — and through
// every EXPRESSION position, where Surelog takes a different function and
// golden's answer is the hier_path § arrayWithIsRecvPath9 already ships.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package pkE151;
  class itE151;
    int offset;
  endclass
  class holdE151;
    int    iq[$];
    itE151 tq[$];
    task bodyE151;
      int r;
      int i;
      // ---- STATEMENT position, one container per cell (THE LAW) ----
      iq.sort() with ( item );                       // body top level
      begin iq.sort() with ( item ); end             // plain begin
      begin : nm151 iq.sort() with ( item ); end     // named begin
      if (r == 1) iq.sort() with ( item );           // if branch
      if (r == 2) ; else iq.sort() with ( item );    // else branch
      for (i = 0; i < 2; i++) iq.sort() with ( item );   // for body
      while (r == 3) iq.sort() with ( item );        // while body
      repeat (2) iq.sort() with ( item );            // repeat body
      forever begin
        iq.sort() with ( item );                     // forever body
        break;
      end
      case (r)
        4: iq.sort() with ( item );                  // case arm
        default: iq.rsort() with ( item );           // case default
      endcase
      fork begin
        // THE CORPUS HEAD'S OWN CONTAINER
        if (iq.size() > 0)
          tq.sort() with ( item.offset );
      end join
      fork
        iq.sort() with ( item );                     // fork arm, bare
      join_none
      // ---- EXPRESSION positions (the fence) ----
      r = iq.sum() with ( item );                    // assignment rvalue
      r = 1 + (iq.sum() with ( item ));              // binary operand
      r = (r > 0) ? (iq.sum() with ( item )) : 0;    // ternary operand
      $display("%0d", iq.sum() with ( item ));       // system-call argument
      if (iq.sum() with ( item ))  r = 5;            // if condition
      while (iq.sum() with ( item ) > 99) r = 6;     // while condition
      case (iq.sum() with ( item ))                  // case selector
        7: r = 7;
        default: r = 8;
      endcase
    endtask
  endclass
endpackage
