// Delayed signals for $setuphold and $recrem

module specify7;

    reg clk = 1'b0;
    reg d = 1'b0;
    reg rst_n = 1'b0;
    reg failed = 1'b0;

    sub i_sub(
        .clk   (clk),
        .d     (d),
        .rst_n (rst_n)
    );

    task check;
        begin
            #1;
            if (i_sub.delayed_clk !== clk || i_sub.delayed_d !== d
                || i_sub.delayed_rst_n !== rst_n) begin
                $display("FAILED at %t: %b/%b %b/%b %b/%b", $time,
                         i_sub.delayed_clk, clk, i_sub.delayed_d, d,
                         i_sub.delayed_rst_n, rst_n);
                failed = 1'b1;
            end
        end
    endtask

    initial
    begin
        check;
        rst_n = 1'b1;   check;
        #5 d = 1'b1;    check;
        #5 clk = 1'b1;  check;
        #5 d = 1'b0;    check;
        #5 clk = 1'b0;  check;
        #5 d = 1'bx;    check;
        #5 clk = 1'b1;  check;
        #5 rst_n = 1'b0; check;

        if (failed)
            $display("FAILED");
        else
            $display("PASSED");
        $finish;
    end

endmodule

module sub(
    input clk,
    input d,
    input rst_n
);

  reg notifier;
  wire delayed_clk, delayed_d, delayed_rst_n;

  specify
    // Same delayed signals named by several timing checks
    $setuphold(posedge clk, posedge d, 1, 1, notifier, , , delayed_clk, delayed_d);
    $setuphold(posedge clk, negedge d, 1, 1, notifier, , , delayed_clk, delayed_d);
    $recrem(posedge rst_n, posedge clk, 1, 1, notifier, , , delayed_rst_n, delayed_clk);
  endspecify

endmodule
