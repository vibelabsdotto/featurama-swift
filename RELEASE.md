# Releasing featurama-swift

## Voraussetzungen

- Du bist auf dem `main` Branch und alles ist gepusht
- CI ist grün (Build + Tests)
- [GitHub CLI](https://cli.github.com/) ist installiert und authentifiziert (`gh auth status`)

## Release-Schritte

### 1. Version festlegen

Wir nutzen [Semantic Versioning](https://semver.org/):

- **Patch** (0.3.x): Bugfixes, keine API-Änderungen
- **Minor** (0.x.0): Neue Features, abwärtskompatibel
- **Major** (x.0.0): Breaking Changes

### 2. Tag erstellen und pushen

```bash
git tag <VERSION>
git push origin <VERSION>
```

Beispiel:

```bash
git tag 0.4.0
git push origin 0.4.0
```

### 3. GitHub Release erstellen

```bash
gh release create <VERSION> --repo vibelabsdotto/featurama-swift --title "<VERSION>" --notes "Beschreibung"
```

Beispiel:

```bash
gh release create 0.4.0 --repo vibelabsdotto/featurama-swift --title "0.4.0" --notes "$(cat <<'EOF'
## Was ist neu

- Feature X hinzugefügt
- Bug Y behoben
EOF
)"
```

### 4. Überprüfen

- Release ist sichtbar unter: https://github.com/vibelabsdotto/featurama-swift/releases
- Nutzer können die neue Version sofort über SPM beziehen:

```swift
.package(url: "https://github.com/vibelabsdotto/featurama-swift.git", from: "<VERSION>")
```

## Hinweise

- Es gibt keinen Build-/Publish-Schritt — SPM löst Versionen direkt über Git Tags auf
- Ein Tag kann **nicht** nachträglich geändert werden. Bei Fehlern: neuen Patch-Release machen
- GitHub Releases erzeugen Notifications für Repo-Watcher
