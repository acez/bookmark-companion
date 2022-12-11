SUBQUERY (
    extensionItems,
    $extensionItem,
        SUBQUERY (
            $extensionItem.attachments,
            $attachment,
            ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url"
        ).@count == $extensionItem.attachments.@count
).@count == 1