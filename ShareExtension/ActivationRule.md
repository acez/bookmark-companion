SUBQUERY (
    extensionItems,
    $extensionItem,
        SUBQUERY (
            $extensionItem.attachments,
            $attachment,
            ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url"
        ).@count == 1
).@count == 1
