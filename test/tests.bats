@test "Test bats" {
    run echo 'foo'
    [ "$status" -eq 0 ]
}
