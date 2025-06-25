// CLI参数解析测试

test "test_basic_parsing" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("name", "n", "name", true, "", "名称参数")
    .add_int_arg("count", "c", "count", false, "10", "数量参数")
    .add_flag("verbose", "v", "verbose", "详细输出")
  
  let args = ["--name", "test", "-c", "5", "--verbose"]
  let parsed = parser.parse(args)
  
  assert_false(parsed.has_errors())
  assert_eq(parsed.get_string("name"), Some("test"))
  assert_eq(parsed.get_int("count"), Some(5))
  assert_true(parsed.get_bool("verbose"))
}

test "test_short_args" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("file", "f", "file", true, "", "文件路径")
    .add_flag("debug", "d", "debug", "调试模式")
  
  let args = ["-f", "test.txt", "-d"]
  let parsed = parser.parse(args)
  
  assert_false(parsed.has_errors())
  assert_eq(parsed.get_string("file"), Some("test.txt"))
  assert_true(parsed.get_bool("debug"))
}

test "test_default_values" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("output", "o", "output", false, "./default", "输出目录")
    .add_int_arg("port", "p", "port", false, "8080", "端口号")
  
  let args : Array[String] = []
  let parsed = parser.parse(args)
  
  assert_false(parsed.has_errors())
  assert_eq(parsed.get_string("output"), Some("./default"))
  assert_eq(parsed.get_int("port"), Some(8080))
}

test "test_required_args_missing" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("input", "i", "input", true, "", "输入文件")
  
  let args : Array[String] = []
  let parsed = parser.parse(args)
  
  assert_true(parsed.has_errors())
  assert_true(parsed.get_errors().contains("缺少必需参数"))
}

test "test_unknown_args" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("name", "n", "name", false, "", "名称")
  
  let args = ["--unknown", "value"]
  let parsed = parser.parse(args)
  
  assert_true(parsed.has_errors())
  assert_true(parsed.get_errors().contains("未知参数"))
}

test "test_positional_args" {
  let parser = new_parser("test", "测试程序")
    .add_flag("verbose", "v", "verbose", "详细输出")
  
  let args = ["--verbose", "file1.txt", "file2.txt"]
  let parsed = parser.parse(args)
  
  assert_false(parsed.has_errors())
  assert_true(parsed.get_bool("verbose"))
  assert_eq(parsed.positional.length(), 2)
  assert_eq(parsed.positional[0], "file1.txt")
  assert_eq(parsed.positional[1], "file2.txt")
}

test "test_help_generation" {
  let parser = new_parser("myapp", "我的应用程序")
    .add_string_arg("input", "i", "input", true, "", "输入文件路径")
    .add_flag("verbose", "v", "verbose", "启用详细输出")
  
  let help = parser.help()
  
  assert_true(help.contains("用法: myapp"))
  assert_true(help.contains("我的应用程序"))
  assert_true(help.contains("--input"))
  assert_true(help.contains("-i"))
  assert_true(help.contains("--verbose"))
  assert_true(help.contains("-v"))
  assert_true(help.contains("必需"))
}

test "test_mixed_args" {
  let parser = new_parser("test", "测试程序")
    .add_string_arg("config", "c", "config", false, "config.json", "配置文件")
    .add_int_arg("threads", "t", "threads", false, "4", "线程数")
    .add_bool_arg("enable", "e", "enable", false, "true", "启用功能")
    .add_flag("quiet", "q", "quiet", "静默模式")
  
  let args = ["-c", "custom.json", "--threads", "8", "--enable", "false", "-q", "input.txt"]
  let parsed = parser.parse(args)
  
  assert_false(parsed.has_errors())
  assert_eq(parsed.get_string("config"), Some("custom.json"))
  assert_eq(parsed.get_int("threads"), Some(8))
  assert_eq(parsed.get_bool("enable"), false)
  assert_true(parsed.get_bool("quiet"))
  assert_eq(parsed.positional.length(), 1)
  assert_eq(parsed.positional[0], "input.txt")
}