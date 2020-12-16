import 'dart:convert';

import 'package:enough_mail/mime_message.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

import 'text_search.dart';

class ConvertTagsTextProcessor implements TextTransformer {
  const ConvertTagsTextProcessor();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    return text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }
}

class MergeAttachedImageTextProcessor extends TextTransformer {
  const MergeAttachedImageTextProcessor();

  @override
  String transform(
      String text, MimeMessage message, TransformConfiguration configuration) {
    final search = TextSearchIterator('[cid:', text, endSearchPattern: ']');
    String nextImageDefinition;
    while ((nextImageDefinition = search.next()) != null) {
      final cid = nextImageDefinition.substring(
          '[cid:'.length, nextImageDefinition.length - 2);
      final part = message.getPartWithContentId(cid);
      if (part != null) {
        final contentType = part.getHeaderContentType();
        final mediaType = contentType?.mediaType?.text ?? 'image/png';
        final binary = part.decodeContentBinary();
        final base64Data = base64Encode(binary);
        text = text.replaceFirst(nextImageDefinition,
            '<img src="data:$mediaType;base64,$base64Data" alt="${part.getHeaderContentDisposition()?.filename}"/>');
      }
    }
    return text;
  }
}
