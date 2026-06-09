/*
    This file is part of the KDE libraries
    SPDX-FileCopyrightText: 2006, 2007 Thomas Braxton <kde.braxton@gmail.com>
    SPDX-FileCopyrightText: 1999 Preston Brown <pbrown@kde.org>
    SPDX-FileCopyrightText: 1997 Matthias Kalle Dalheimer <kalle@kde.org>
    SPDX-FileCopyrightText: 2001 Waldo Bastian <bastian@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

public class KConfigGroup: KConfigBase {
    //=====================
    // Private Variables
    //=====================
    // KSharedConfig::Ptr sOwner;
    private var _owner: KConfig?
    private var _parent: KConfigGroup?
    private var _name: String

    private var _immutable: Bool // : 1; // is this group immutable?
    private var _const: Bool // : 1; // is this group read-only?

    //====================
    // Private Methods
    //====================
    private init(_ owner: KConfig?, _ isImmutable: Bool, _ isConst: Bool, _ name: String) {
        _owner = owner
        _immutable = isImmutable
        _const = isConst
        _name = name

        if !_owner!.name.isEmpty && _owner!.accessMode() == .noAccess {
            print("qCWarning: Created a KConfigGroup on an inaccessible config location \(_owner!.name) \(name)")
        }
    }

    internal init(/* const KSharedConfigPtr &owner */ _ owner: KConfig?, _ name: String) {
        _owner = owner
        _name = name
        _immutable = name.isEmpty
            ? owner?.isImmutable() ?? false
            : owner?.isGroupImmutable(name) ?? false
        _const = false

        if !(_owner?.name.isEmpty ?? false) && _owner?.accessMode() == .noAccess {
            print("Created a KConfigGroup on an inaccessible config location"
                + " \(_owner?.name ?? "(nil)") \(name)"
            )
        }
    }

    private init(_ parent: KConfigGroup?, _ isImmutable: Bool, _ isConst: Bool, _ name: String) {
        _owner = parent?._owner
        _immutable = isImmutable
        _const = isConst
        _name = name

        if let parent = parent {
            if !(parent._name.isEmpty) {
                _parent = parent
            }
        }
    }

    private func fullName() -> String {
        if _parent == nil {
            return self.name()
        } else {
            return _parent!.fullName(_name)
        }
    }

    private func name() -> String {
        if _name.isEmpty {
            return "<default>"
        }
        return _name
    }

    private func fullName(_ aGroup: String) -> String
    {
        if _name.isEmpty {
            return aGroup
        }
        return self.fullName() + "\u{001D}" + aGroup
    }

    private func config() -> KConfig?
    {
        // Q_ASSERT_X(isValid(), "KConfigGroup::config", "accessing an invalid group");

        return _owner
    }

    /*
    static QExplicitlySharedDataPointer<KConfigGroupPrivate> create(KConfigBase *master, const QString &name, bool isImmutable, bool isConst)
    {
        QExplicitlySharedDataPointer<KConfigGroupPrivate> data;
        if (dynamic_cast<KConfigGroup *>(master)) {
            data = new KConfigGroupPrivate(static_cast<KConfigGroup *>(master), isImmutable, isConst, name);
        } else {
            data = new KConfigGroupPrivate(dynamic_cast<KConfig *>(master), isImmutable, isConst, name);
        }
        return data;
    }

    static QByteArray serializeList(const QList<QByteArray> &list);
    static QStringList deserializeList(const QString &data);
    */

    //==================
    // KConfigBase
    //==================
    public func groupList() -> [String] {
        // Q_ASSERT_X(isValid(), "KConfigGroup::groupList", "accessing an invalid group");

        return _owner?.groupList(self.fullName()) ?? []
    }

    public func hasGroup(_ group: String) -> Bool {
        // Q_ASSERT_X(isValid(), "KConfigGroup::hasGroupImpl", "accessing an invalid group");

        return _owner?.hasGroup(self.fullName(group)) ?? false
    }

    public func group(_ groupName: String) -> KConfigGroup {
        // Q_ASSERT_X(isValid(), "KConfigGroup::groupImpl", "accessing an invalid group");
        // Q_ASSERT_X(!aGroup.isEmpty(), "KConfigGroup::groupImpl", "can not have an unnamed child group");

        var newGroup = KConfigGroup(self, self.isGroupImmutable(groupName)), _const, groupName)

        // newGroup.d = new KConfigGroupPrivate(this, isGroupImmutableImpl(aGroup), d->bConst, aGroup);

        return newGroup
    }

    public func deleteGroup(_ group: String, _ flags: WriteConfigFlags) {
        // Q_ASSERT_X(isValid(), "KConfigGroup::deleteGroup", "accessing an invalid group");
        // Q_ASSERT_X(!d->bConst, "KConfigGroup::deleteGroup", "deleting a read-only group");

        _owner?.deleteGroup(self.fullName(), flags)
    }

    public func sync() -> Bool {
        // Q_ASSERT_X(isValid(), "KConfigGroup::sync", "accessing an invalid group");

        if !_const {
            return _owner?.sync() ?? false
        }

        return false
    }

    public func markAsClean() {
        // Q_ASSERT_X(isValid(), "KConfigGroup::markAsClean", "accessing an invalid group");

        _owner?.markAsClean()
    }

    public func accessMode() -> AccessMode {
        // Q_ASSERT_X(isValid(), "KConfigGroup::accessMode", "accessing an invalid group");

        return _owner?.accessMode() ?? .noAccess
    }

    public func isImmutable() -> Bool {
        // Q_ASSERT_X(isValid(), "KConfigGroup::isImmutable", "accessing an invalid group");

        return _immutable
    }

    public func isGroupImmutable(_ group: String) -> Bool {
        // Private.
        // Q_ASSERT_X(isValid(), "KConfigGroup::isGroupImmutableImpl", "accessing an invalid group");

        if !self.hasGroup(group) { // group doesn't exist yet
            return _immutable // child groups are immutable if the parent is immutable.
        }

        return _owner?.isGroupImmutable(self.fullName(group)) ?? false

        // Public.
    }
}
