// MCP 工具：获取当前时间
//
// 为 LLM 提供获取当前时间的能力，
// 支持多种时间格式输出。

import 'package:intl/intl.dart';

import '../models/mcp_tool.dart';

/// 获取当前时间 MCP 工具
///
/// 返回当前时间信息，支持多种格式。
class NowTimeTool extends McpTool {
  @override
  final String name = 'now_time';

  @override
  final String description = '获取当前时间，支持多种时间格式输出';

  @override
  final bool enabled = true;

  @override
  final Map<String, dynamic> inputSchema = {
    'type': 'object',
    'properties': {
      'format': {
        'type': 'string',
        'description': '输出格式: full（完整日期时间，默认）, date（仅日期）, time（仅时间）, iso8601（ISO8601格式）, timestamp（Unix时间戳）, custom（自定义格式）',
        'enum': ['full', 'date', 'time', 'iso8601', 'timestamp', 'custom'],
      },
      'timezone': {
        'type': 'string',
        'description': '时区偏移（小时），如 8 表示 UTC+8（中国时间），默认为 8',
      },
      'custom_format': {
        'type': 'string',
        'description': '自定义格式字符串（当 format 为 custom 时使用），如 yyyy-MM-dd HH:mm:ss',
      },
    },
  };

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> arguments) async {
    final format = arguments['format'] as String? ?? 'full';
    final timezoneOffset = int.tryParse(arguments['timezone'] as String? ?? '8') ?? 8;
    final customFormat = arguments['custom_format'] as String? ?? 'yyyy-MM-dd HH:mm:ss';

    try {
      final now = DateTime.now().toUtc().add(Duration(hours: timezoneOffset));

      switch (format) {
        case 'date':
          return {
            'success': true,
            'date': DateFormat('yyyy-MM-dd').format(now),
            'timezone': 'UTC+$timezoneOffset',
          };
        case 'time':
          return {
            'success': true,
            'time': DateFormat('HH:mm:ss').format(now),
            'timezone': 'UTC+$timezoneOffset',
          };
        case 'iso8601':
          return {
            'success': true,
            'datetime': now.toIso8601String(),
            'timezone': 'UTC+$timezoneOffset',
          };
        case 'timestamp':
          return {
            'success': true,
            'timestamp': now.millisecondsSinceEpoch,
            'timezone': 'UTC+$timezoneOffset',
          };
        case 'custom':
          return {
            'success': true,
            'datetime': DateFormat(customFormat).format(now),
            'timezone': 'UTC+$timezoneOffset',
          };
        case 'full':
        default:
          return {
            'success': true,
            'datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
            'date': DateFormat('yyyy-MM-dd').format(now),
            'time': DateFormat('HH:mm:ss').format(now),
            'weekday': _getWeekday(now.weekday),
            'timezone': 'UTC+$timezoneOffset',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '获取时间失败: $e',
      };
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return weekdays[weekday - 1];
  }
}
