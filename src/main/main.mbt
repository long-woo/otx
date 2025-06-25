fn main {
  // 创建CLI解析器
  let parser = @lib.new_parser("otx", "OpenAPI规范的API文档生成工具")
    .add_string_arg("input", "i", "input", true, "", "输入的OpenAPI规范文件路径")
    .add_string_arg("output", "o", "output", false, "./generated", "输出目录")
    .add_string_arg("lang", "l", "lang", false, "typescript", "生成代码的语言")
    .add_flag("verbose", "v", "verbose", "启用详细输出")
    .add_flag("help", "h", "help", "显示帮助信息")
  
  // 模拟命令行参数（实际使用时应该从系统获取）
  let test_args = ["--input", "api.yaml", "-o", "./output", "--verbose"]
  
  // 解析参数
  let parsed = parser.parse(test_args)
  
  // 检查是否需要显示帮助
  if parsed.get_bool("help") {
    println(parser.help())
    return
  }
  
  // 检查解析错误
  if parsed.has_errors() {
    println("错误:")
    println(parsed.get_errors())
    return
  }
  
  // 显示解析结果
  println("=== CLI参数解析结果 ===")
  
  match parsed.get_string("input") {
    Some(input) => println("输入文件: " + input)
    None => println("未指定输入文件")
  }
  
  match parsed.get_string("output") {
    Some(output) => println("输出目录: " + output)
    None => println("未指定输出目录")
  }
  
  match parsed.get_string("lang") {
    Some(lang) => println("目标语言: " + lang)
    None => println("未指定目标语言")
  }
  
  if parsed.get_bool("verbose") {
    println("详细模式: 已启用")
  } else {
    println("详细模式: 未启用")
  }
  
  if parsed.positional.length() > 0 {
    println("位置参数: " + parsed.positional.join(", "))
  }
  
  println("\n=== 帮助信息 ===")
  println(parser.help())
}
