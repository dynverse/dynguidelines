context("Test formatters")

# test time formatters
expect_equal(format_time(10), "10s")
expect_equal(process_time("10s"), 10)

expect_equal(format_time(0.1, min = 1), "<1s")
expect_equal(format_time(10, max = 1), ">1s")

expect_error(process_time("10GB"))


# test memory formatters
expect_equal(format_memory(10^9), "1GB")
expect_equal(process_memory("1GB"), 10^9)

expect_equal(format_memory(10^8, min =  10^9), "<1GB")
expect_equal(format_memory(10^10, max =  10^9), ">1GB")
